import csv
import os
import logging

logger = logging.getLogger(__name__)

class Database:
    def __init__(self, filepath: str):
        self.filepath = filepath

    def load_existing_ids(self) -> set[str]:
        """Load the existing database to avoid duplicates."""
        if not os.path.exists(self.filepath):
            logger.info(f"Database file {self.filepath} does not exist. Starting fresh.")
            return set()
        
        existing_ids = set()
        with open(self.filepath, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                existing_ids.add(row['id'])
        logger.info(f"Loaded {len(existing_ids)} existing papers from database.")
        return existing_ids

    def save_papers(self, papers: list[dict]):
        """Save a list of triaged papers to the database."""
        if not papers:
            return

        file_exists = os.path.exists(self.filepath)
        
        with open(self.filepath, 'a', encoding='utf-8', newline='') as f:
            fieldnames = ['id', 'title', 'authors', 'published', 'source', 'triage_status', 'summary', 'url']
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            
            if not file_exists:
                writer.writeheader()
                
            for paper in papers:
                writer.writerow(paper)
        
        logger.info(f"Saved {len(papers)} papers to {self.filepath}.")
