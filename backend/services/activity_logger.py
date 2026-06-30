import logging
import os
import sys

# Create logs directory if it doesn't exist
os.makedirs("logs", exist_ok=True)

file_handler = logging.FileHandler("logs/user_activity.log")
console_handler = logging.StreamHandler(sys.stdout)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(message)s",
    handlers=[file_handler, console_handler]
)


def log_activity(username: str, action: str, details: str = ""):
    logging.info(
        f"User={username} | Action={action} | {details}"
    )
