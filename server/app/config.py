import os
from dotenv import load_dotenv
import urllib.parse

load_dotenv()

# Database configuration
DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "parkflow")

# URL-encode password to handle special characters
encoded_password = urllib.parse.quote_plus(DB_PASSWORD)
DATABASE_URL = f"mysql+pymysql://{DB_USER}:{encoded_password}@{DB_HOST}/{DB_NAME}"

# JWT configuration
JWT_SECRET = os.getenv("JWT_SECRET", "supersecretkey")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60))

EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")
GMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")