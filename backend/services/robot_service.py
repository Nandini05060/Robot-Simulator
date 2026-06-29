from services.state_manager import state_manager
from typing import Union


def get_all_robots():
    return state_manager.get_all()


def get_robot(robot_id: Union[int, str]):
    return state_manager.get_robot(robot_id)