import os
import logging

class Config:
    DATABASE_FILE = 'papers_database.csv'
    DAYS_BACK = 7
    GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY", "")
    GEMINI_MODEL = "gemini-3.6-flash"
    MAX_WORKERS = 5
    HTTP_TIMEOUT = 30
    DEFAULT_QUERY = "Recent advances in AI alignment, mechanistic interpretability, and reinforcement learning from human feedback."

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    # Mute noisy internal SDK loggers
    logging.getLogger("google_genai").setLevel(logging.WARNING)
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("httpcore").setLevel(logging.WARNING)
