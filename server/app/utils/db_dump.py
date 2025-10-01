# app/utils/db_dump.py
import subprocess
import os
import threading
from ..config import DB_USER, DB_PASSWORD, DB_HOST, DB_NAME


def update_database_dump():
    """
        Update the parkflow.sql dump file
    """
    try:
        # Define the path to your parkflow.sql file
        dump_file = "parkflow.sql"

        # Create mysqldump command
        cmd = [
            'mysqldump',
            '-u', DB_USER,
            f'-p{DB_PASSWORD}',
            '-h', DB_HOST,
            DB_NAME
        ]

        # Update the parkflow.sql file
        with open(dump_file, 'w') as f:
            result = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, text=True)

            if result.returncode != 0:
                print(f"mysqldump error: {result.stderr}")
                return False

        print(f"Database dump updated: {dump_file}")
        return True

    except Exception as e:
        print(f"Error updating dump: {e}")
        return False


def trigger_dump_update():
    """
        Trigger dump update in background thread
    """
    try:
        thread = threading.Thread(target=update_database_dump, daemon=True)
        thread.start()
        print("Database dump update triggered...")

    except Exception as e:
        print(f"Failed to trigger dump update: {e}")
