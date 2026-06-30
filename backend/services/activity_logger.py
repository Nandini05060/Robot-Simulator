import logging
import os

# Create logs directory if it doesn't exist
os.makedirs("logs", exist_ok=True)

logging.basicConfig(
    filename="logs/user_activity.log",
    level=logging.INFO,
    format="%(asctime)s | %(message)s",
)


def log_activity(username: str, action: str, details: str = ""):
    logging.info(
        f"User={username} | Action={action} | {details}"
    )
