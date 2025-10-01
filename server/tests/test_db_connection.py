import sys
import os

# Add the parent directory to sys.path
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from app.config import DATABASE_URL
from sqlalchemy import create_engine, text


def test_connection():
    print(f"Testing connection to: {DATABASE_URL}")

    try:
        engine = create_engine(DATABASE_URL)
        with engine.connect() as conn:
            # Test basic connection
            result = conn.execute(text("SELECT 1"))
            print("✓ Database connection successful!")

            # Check if tables exist
            result = conn.execute(text("SHOW TABLES;"))
            tables = [row[0] for row in result]
            print(f"Found {len(tables)} tables: {tables}")

            return True

    except Exception as e:
        print(f"✗ Database connection failed: {e}")
        return False


if __name__ == "__main__":
    test_connection()