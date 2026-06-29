from services.robot_service import get_robot
from data.maps import MAP_WIDTH, MAP_HEIGHT, OBSTACLES

DIRECTIONS = ["North", "East", "South", "West"]


def rotate_robot(robot, rotation):

    index = DIRECTIONS.index(robot.direction)

    if rotation == "left":
        index = (index - 1) % 4
        robot.angle = (robot.angle - 90) % 360

    elif rotation == "right":
        index = (index + 1) % 4
        robot.angle = (robot.angle + 90) % 360

    robot.direction = DIRECTIONS[index]


def move_robot(robot_id: int, command: str):

    robot = get_robot(robot_id)

    if robot is None:
        return {
            "success": False,
            "message": "Robot not found"
        }

    # ==========================
    # MANUAL OVERRIDE
    # ==========================
    if hasattr(robot, "auto_navigation") and robot.auto_navigation:
        robot.auto_navigation = False
        robot.mode = "Manual"
        robot.status = "Manual Override"
    # ==========================

    if robot.battery <= 0:
        return {
            "success": False,
            "message": "Battery depleted"
        }

    if command == "rotate_left":
        rotate_robot(robot, "left")
        robot.battery = max(0, robot.battery - 1)

        return {
            "success": True,
            "robot": robot
        }

    if command == "rotate_right":
        rotate_robot(robot, "right")
        robot.battery = max(0, robot.battery - 1)

        return {
            "success": True,
            "robot": robot
        }

    new_x = robot.x
    new_y = robot.y

    if command == "forward":

        if robot.direction == "North":
            new_y -= robot.speed

        elif robot.direction == "South":
            new_y += robot.speed

        elif robot.direction == "East":
            new_x += robot.speed

        elif robot.direction == "West":
            new_x -= robot.speed

    elif command == "backward":

        if robot.direction == "North":
            new_y += robot.speed

        elif robot.direction == "South":
            new_y -= robot.speed

        elif robot.direction == "East":
            new_x -= robot.speed

        elif robot.direction == "West":
            new_x += robot.speed

    if new_x < 0 or new_x >= MAP_WIDTH:
        return {"success": False, "message": "Boundary reached"}

    if new_y < 0 or new_y >= MAP_HEIGHT:
        return {"success": False, "message": "Boundary reached"}

    if (new_x, new_y) in OBSTACLES:
        return {"success": False, "message": "Obstacle detected"}

    robot.x = new_x
    robot.y = new_y
    robot.status = "Moving"
    robot.battery = max(0, robot.battery - 1)

    return {
        "success": True,
        "robot": robot
    }