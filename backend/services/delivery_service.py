from services.robot_service import get_robot


def start_delivery(robot_id: str, destination: dict):

    robot = get_robot(robot_id)

    if robot is None:
        return {
            "success": False,
            "message": "Robot not found"
        }

    robot.mode = "Delivery"
    robot.status = "Delivering"
    robot.current_task = "Delivering Package"

    return {
        "success": True,
        "robot": robot,
        "destination": destination
    }


def stop_delivery(robot_id: str):

    robot = get_robot(robot_id)

    if robot is None:
        return {
            "success": False,
            "message": "Robot not found"
        }

    robot.mode = "Manual"
    robot.status = "Idle"
    robot.current_task = "None"

    return {
        "success": True,
        "robot": robot
    }