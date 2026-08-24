import logging
import json
import time
import urllib.request
import urllib.parse
from datetime import datetime, timedelta
from typing import List, Dict, Any
from concurrent.futures import ThreadPoolExecutor, as_completed
from tqdm import tqdm
import socket

old_getaddrinfo = socket.getaddrinfo
def new_getaddrinfo(*args, **kwargs):
    responses = old_getaddrinfo(*args, **kwargs)
    return [r for r in responses if r[0] == socket.AF_INET]
socket.getaddrinfo = new_getaddrinfo


from google import genai
from google.genai import types
from config import Config

logger = logging.getLogger(__name__)

class Agent:
    def __init__(self, api_key: str = Config.GEMINI_API_KEY, model_name: str = Config.GEMINI_MODEL):
        self.api_key = api_key
        self.model_name = model_name
        self.http_options = types.HttpOptions(timeout=Config.HTTP_TIMEOUT * 1000)
        self.afc_config = types.GenerateContentConfig(
            automatic_function_calling=types.AutomaticFunctionCallingConfig(disable=True),
            http_options=self.http_options
        )
        
        if self.api_key:
            self.client = genai.Client(
                api_key=self.api_key,
                http_options=self.http_options
            )
        else:
            self.client = None
            logger.warning("GEMINI_API_KEY not provided. LLM operations will fail fast.")

    def generate_keywords(self, query: str) -> List[str]:
        """Use Gemini to extract search keywords from a natural language line."""
        if not self.client:
            logger.warning("GEMINI_API_KEY is missing. Using fallback default keywords.")
            return ['"AI alignment"', '"mechanistic interpretability"']
            
        prompt = f"""
You are an expert academic librarian. 
A researcher has provided the following topic or question: "{query}"

Extract 3-5 precise and highly relevant search keywords or exact phrases to query in an academic database (like OpenAlex/arXiv).
Format your response ONLY as a valid JSON list of strings, with no markdown, no backticks, and no extra text.
Example: ["\\"AI alignment\\"", "mechanistic interpretability", "\\"reinforcement learning from human feedback\\""]
"""
        try:
            response = self.client.models.generate_content(
                model=self.model_name,
                contents=prompt
            )
            text = response.text.strip()
            if text.startswith("```json"):
                text = text[7:]
            if text.startswith("```"):
                text = text[3:]
            if text.endswith("```"):
                text = text[:-3]
                
            keywords = json.loads(text.strip())
            if isinstance(keywords, list) and all(isinstance(k, str) for k in keywords):
                return keywords
            else:
                raise ValueError("Response is not a valid list of strings.")
        except Exception as e:
            logger.error(f"Error generating keywords with Gemini: {e}")
            raise RuntimeError(f"Failed to generate keywords from query: {e}")

    def search_openalex(self, keywords: List[str], days_back: int = Config.DAYS_BACK, timeout: int = Config.HTTP_TIMEOUT) -> List[Dict[str, Any]]:
        """Search OpenAlex API for papers matching the keywords with strict timeouts."""
        papers = []
        from_date = (datetime.now() - timedelta(days=days_back)).strftime('%Y-%m-%d')
        
        for kw in keywords:
            encoded_kw = urllib.parse.quote(kw)
            url = f'https://api.openalex.org/works?search={encoded_kw}&filter=from_publication_date:{from_date}&per-page=50'
            
            logger.info(f"Querying OpenAlex for keyword: {kw}")
            try:
                req = urllib.request.Request(url, headers={'User-Agent': 'mailto:user@example.com'})
                with urllib.request.urlopen(req, timeout=timeout) as response:
                    data = json.loads(response.read())
                    
                    for work in data.get('results', []):
                        source = "Unknown"
                        if work.get('primary_location') and work['primary_location'].get('source'):
                            source = work['primary_location']['source'].get('display_name', 'Unknown')
                        
                        paper_id = work.get('id', '').split('/')[-1]
                        title = work.get('title', '')
                        if not title:
                            continue
                        
                        abstract = ""
                        abs_idx = work.get('abstract_inverted_index', {})
                        if abs_idx:
                            word_list = []
                            for word, positions in abs_idx.items():
                                for pos in positions:
                                    word_list.append((pos, word))
                            word_list.sort()
                            abstract = " ".join([w for pos, w in word_list])
                        
                        published = work.get('publication_date', '')
                        authors = ", ".join([auth.get('author', {}).get('display_name', '') for auth in work.get('authorships', [])])
                        url_link = work.get('doi') or work.get('id')
                        
                        papers.append({
                            'id': paper_id,
                            'title': title,
                            'summary': abstract,
                            'authors': authors,
                            'published': published,
                            'source': source,
                            'url': url_link
                        })
            except Exception as e:
                logger.error(f"Error fetching OpenAlex for {kw}: {e}")
            
            time.sleep(0.3)
            
        return papers

    def triage_paper(self, paper: Dict[str, Any]) -> Dict[str, Any]:
        """Triage a single paper with Gemini LLM."""
        if not self.client:
            paper['triage_status'] = 'skim'
            return paper
        
        prompt = f"""
You are an expert AI researcher. Triage the following paper into exactly one of these categories:
- keep (highly relevant and important methodology)
- skim (relevant but maybe less important)
- drop (irrelevant or low quality)
- duplicate (already seen this exact concept)
- outside scope (tangential)
- weak method (relevant but flawed or weak methodology)

Respond ONLY with the category name in lowercase.

Title: {paper['title']}
Source: {paper['source']}
Abstract: {paper['summary']}
"""
        try:
            response = self.client.models.generate_content(
                model=self.model_name,
                contents=prompt
            )
            category = response.text.strip().lower()
            
            valid_categories = ['keep', 'skim', 'drop', 'duplicate', 'outside scope', 'weak method']
            if category in valid_categories:
                paper['triage_status'] = category
            else:
                for valid in valid_categories:
                    if valid in category:
                        paper['triage_status'] = valid
                        break
                else:
                    paper['triage_status'] = 'skim'
        except Exception as e:
            logger.error(f"Error during Gemini API triage for paper '{paper['title'][:30]}': {e}")
            paper['triage_status'] = 'skim'
            
        return paper

    def process_and_triage(self, new_papers: List[Dict[str, Any]], max_workers: int = Config.MAX_WORKERS) -> List[Dict[str, Any]]:
        """Deduplicate and triage papers in parallel using ThreadPoolExecutor with a tqdm progress bar."""
        seen_ids = set()
        unique_new_papers = []
        for p in new_papers:
            if p['id'] not in seen_ids:
                unique_new_papers.append(p)
                seen_ids.add(p['id'])

        total = len(unique_new_papers)
        if total == 0:
            return []

        logger.info(f"Starting parallel triage for {total} papers using {max_workers} worker threads...")
        
        triaged_papers = []
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            futures = [executor.submit(self.triage_paper, paper) for paper in unique_new_papers]
            
            for future in tqdm(as_completed(futures), total=total, desc="Triaging Papers", unit="paper"):
                try:
                    result = future.result()
                    triaged_papers.append(result)
                except Exception as e:
                    logger.error(f"Worker thread error during triage: {e}")
            
        return triaged_papers
