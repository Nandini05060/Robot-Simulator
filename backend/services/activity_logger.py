import logging
import os
import sys

# Create logs directory if it doesn't exist
os.makedirs("logs", exist_ok=True)

# Create a dedicated logger for activity logging
activity_logger = logging.getLogger("activity")
activity_logger.setLevel(logging.INFO)
activity_logger.propagate = False  # Avoid duplicates in root logger

# Ensure handlers are only added once
if not activity_logger.handlers:
    file_handler = logging.FileHandler("logs/user_activity.log")
    file_handler.setFormatter(logging.Formatter("%(asctime)s | %(message)s"))
    activity_logger.addHandler(file_handler)

    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(logging.Formatter("%(asctime)s | %(message)s"))
    activity_logger.addHandler(console_handler)


def log_activity(username: str, action: str, details: str = ""):
    activity_logger.info(
        f"User={username} | Action={action} | {details}"
    )
