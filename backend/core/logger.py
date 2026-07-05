import logging
import sys

# Configure root logger to output to console if not already configured
root_logger = logging.getLogger()
if not root_logger.handlers:
    root_logger.setLevel(logging.INFO)
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(logging.Formatter("%(asctime)s | %(levelname)s | %(message)s"))
    root_logger.addHandler(handler)

logger = logging.getLogger("robot_simulator")
