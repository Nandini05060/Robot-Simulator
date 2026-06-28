from services.state_manager import state_manager


def get_all_robots():
    return state_manager.get_all()


def get_robot(robot_id: int):
    return state_manager.get_robot(robot_id)