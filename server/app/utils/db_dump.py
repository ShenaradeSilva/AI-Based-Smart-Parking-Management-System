import subprocess
import threading
import os
from ..config import DB_USER, DB_PASSWORD, DB_HOST, DB_NAME

def update_database_dump():
    """
    Update the existing parkflow.sql dump file in the project root.
    """
    try:
        # Full path to parkflow.sql in root folder
        root_folder = os.path.abspath(os.path.join(os.getcwd(), ".."))  # go one level up from server/
        dump_file = os.path.join(root_folder, "parkflow.sql")

        # mysqldump command
        cmd = [
            'mysqldump',  # must be in PATH or use full path
            '-u', DB_USER,
            f'-p{DB_PASSWORD}',
            '-h', DB_HOST,
            DB_NAME
        ]

        # Overwrite existing dump file
        with open(dump_file, 'w') as f:
            result = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, text=True)

        if result.returncode != 0:
            print(f"[DB DUMP ERROR] mysqldump failed: {result.stderr}")
            return False

        print(f"[DB DUMP] Database dump updated: {dump_file}")
        return True

    except Exception as e:
        print(f"[DB DUMP ERROR] Exception: {e}")
        return False


def trigger_dump_update():
    """
    Trigger dump update in a background thread.
    """
    try:
        thread = threading.Thread(target=update_database_dump, daemon=True)
        thread.start()
        print("[DB DUMP] Database dump update triggered in background thread...")
    except Exception as e:
        print(f"[DB DUMP ERROR] Failed to trigger dump update: {e}")
