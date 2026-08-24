import sys
import logging
from collections import defaultdict
from config import Config, setup_logging
from database import Database
from agent import Agent

logger = logging.getLogger(__name__)

def main():
    setup_logging()
    
    # 1. Parse Input Line
    if len(sys.argv) > 1:
        user_query = " ".join(sys.argv[1:])
    else:
        user_query = Config.DEFAULT_QUERY
        logger.info(f"No query provided, using default: '{user_query}'")
        logger.info("Usage: python paper_finder.py <your natural language query/line>")

    # 2. Initialize Agent and DB
    agent = Agent(api_key=Config.GEMINI_API_KEY, model_name=Config.GEMINI_MODEL)
    db = Database(filepath=Config.DATABASE_FILE)

    # 3. Agent: Understand query and generate keywords
    logger.info(f"Generating search keywords based on your query: '{user_query}'")
    keywords = agent.generate_keywords(user_query)
    logger.info(f"Keywords derived: {keywords}")

    # 4. Agent: Search academic databases
    logger.info("Searching OpenAlex (covering arXiv/IEEE/ACM/Springer)...")
    papers = agent.search_openalex(keywords, days_back=Config.DAYS_BACK, timeout=Config.HTTP_TIMEOUT)
    logger.info(f"Found {len(papers)} recent papers from search.")

    # 5. Database: Check for existing delta
    existing_ids = db.load_existing_ids()
    delta_papers = [p for p in papers if p['id'] not in existing_ids]
    logger.info(f"Found {len(delta_papers)} new unique papers (delta).")

    # 6. Agent: Parallel Triage and Priority assignment
    if delta_papers:
        logger.info("Triaging new papers in parallel...")
        triaged_papers = agent.process_and_triage(delta_papers, max_workers=Config.MAX_WORKERS)
        
        # 7. Database: Save results
        db.save_papers(triaged_papers)
        
        # 8. Output Categorized Summary
        grouped = defaultdict(list)
        for p in triaged_papers:
            grouped[p['triage_status'].upper()].append(p)
            
        print("\n=================== TRIAGE RESULTS ===================")
        # Priority order for display
        priority_order = ['KEEP', 'SKIM', 'WEAK METHOD', 'OUTSIDE SCOPE', 'DROP', 'DUPLICATE']
        
        for status in priority_order:
            if status in grouped:
                items = grouped[status]
                print(f"\n--- {status} ({len(items)}) ---")
                for p in items:
                    print(f"• {p['title']}")
                    print(f"  Source: {p['source']} | URL: {p['url']}")
        
        # Any remaining categories
        for status, items in grouped.items():
            if status not in priority_order:
                print(f"\n--- {status} ({len(items)}) ---")
                for p in items:
                    print(f"• {p['title']}")
                    print(f"  Source: {p['source']} | URL: {p['url']}")
        print("======================================================\n")
    else:
        logger.info("No new papers to triage.")

if __name__ == "__main__":
    main()
