import re
from data.robots import robots


def normalize_id(robot_id) -> str:
    match = re.search(r'\d+$', str(robot_id))
    return str(int(match.group())) if match else str(robot_id)


class RobotStateManager:

    def __init__(self):
        self.robots = {robot.id: robot for robot in robots}

    def get_robot(self, robot_id):
        norm_id = normalize_id(robot_id)
        for rid, robot in self.robots.items():
            if normalize_id(rid) == norm_id:
                return robot
        return None

    def get_all(self):
        return list(self.robots.values())

    def update_robot(self, robot):
        self.robots[robot.id] = robot


state_manager = RobotStateManager()