from data.robots import robots


class RobotStateManager:

    def __init__(self):
        self.robots = {robot.id: robot for robot in robots}

    def get_robot(self, robot_id):
        return self.robots.get(robot_id)

    def get_all(self):
        return list(self.robots.values())

    def update_robot(self, robot):
        self.robots[robot.id] = robot


state_manager = RobotStateManager()