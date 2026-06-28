from services.robot_service import get_robot
from data.maps import MAP_WIDTH, MAP_HEIGHT, OBSTACLES

DIRECTIONS = [
    "North", "North-East", "East", "South-East",
    "South", "South-West", "West", "North-West"
]


def rotate_robot(robot, rotation):
    # Coerce to North if current direction is somehow invalid
    if robot.direction not in DIRECTIONS:
        robot.direction = "North"

    index = DIRECTIONS.index(robot.direction)

    # In 8-direction list, 90-degree rotation is 2 steps
    if rotation == "left":
        index = (index - 2) % 8
        robot.angle = (robot.angle - 90) % 360

    elif rotation == "right":
        index = (index + 2) % 8
        robot.angle = (robot.angle + 90) % 360

    robot.direction = DIRECTIONS[index]


def move_robot(robot_id: str, command: str):

    robot = get_robot(robot_id)

    if robot is None:
        return {
            "success": False,
            "message": "Robot not found"
        }
    
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

    # Calculate direction vectors
    dx = 0.0
    dy = 0.0

    if robot.direction == "North":
        dy = -1.0
    elif robot.direction == "North-East":
        dx = 0.707
        dy = -0.707
    elif robot.direction == "East":
        dx = 1.0
    elif robot.direction == "South-East":
        dx = 0.707
        dy = 0.707
    elif robot.direction == "South":
        dy = 1.0
    elif robot.direction == "South-West":
        dx = -0.707
        dy = 0.707
    elif robot.direction == "West":
        dx = -1.0
    elif robot.direction == "North-West":
        dx = -0.707
        dy = -0.707

    if command == "forward":
        new_x += dx * robot.speed
        new_y += dy * robot.speed
    elif command == "backward":
        return {"success": False, "message": "Backward movement is disabled"}

    if new_x < 0 or new_x >= MAP_WIDTH:
        return {"success": False, "message": "Boundary reached"}

    if new_y < 0 or new_y >= MAP_HEIGHT:
        return {"success": False, "message": "Boundary reached"}

    # Grid cell integer collision detection
    if (int(new_x), int(new_y)) in OBSTACLES:
        return {"success": False, "message": "Obstacle detected"}

    robot.x = round(new_x, 2)
    robot.y = round(new_y, 2)
    robot.status = "Moving"
    robot.battery = max(0, robot.battery - 1)

    return {
        "success": True,
        "robot": robot
    }