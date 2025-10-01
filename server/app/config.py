# config.py
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
JWT_SECRET = os.getenv("JWT_SECRET_KEY")
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("JWT_EXPIRE_MINUTES"))

# Email configuration - USE A REAL EMAIL ADDRESS
EMAIL_FROM = os.getenv("EMAIL_FROM", "parkflow.app@gmail.com")  # Change to your real email
EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")  # Your email app password
SMTP_SERVER = os.getenv("SMTP_SERVER", "smtp.gmail.com")
SMTP_PORT = int(os.getenv("SMTP_PORT", "587"))