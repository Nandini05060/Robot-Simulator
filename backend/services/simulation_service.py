import math
from services.robot_service import get_robot
from data.maps import MAP_WIDTH, MAP_HEIGHT, OBSTACLES
from typing import Union

DIRECTIONS = ["North", "East", "South", "West"]


def rotate_robot(robot, rotation):
    if rotation == "left":
        robot.angle = (robot.angle - 90) % 360
    elif rotation == "right":
        robot.angle = (robot.angle + 90) % 360

    # Snap to nearest cardinal direction
    angle_snap = (round(robot.angle / 90) * 90) % 360
    snap_dirs = {0: "North", 90: "East", 180: "South", 270: "West"}
    robot.direction = snap_dirs.get(angle_snap, "North")


def move_robot(robot_id: Union[int, str], command: str):
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

    # Handle rotation in-place (no translation)
    if command == "rotate_left":
        rotate_robot(robot, "left")
        robot.status = "Rotating"
        robot.battery = max(0, robot.battery - 1)
        return {
            "success": True,
            "robot": robot
        }
    elif command == "rotate_right":
        rotate_robot(robot, "right")
        robot.status = "Rotating"
        robot.battery = max(0, robot.battery - 1)
        return {
            "success": True,
            "robot": robot
        }

    new_x = robot.x
    new_y = robot.y

    # Calculate translation based on current heading
    rad = math.radians(robot.angle)

    if command == "forward":
        # 0 is North (new_y -= speed), 90 is East (new_x += speed), 180 is South (new_y += speed), 270 is West (new_x -= speed)
        new_x = round(robot.x + robot.speed * math.sin(rad), 2)
        new_y = round(robot.y - robot.speed * math.cos(rad), 2)

    elif command == "backward":
        new_x = round(robot.x - robot.speed * math.sin(rad), 2)
        new_y = round(robot.y + robot.speed * math.cos(rad), 2)

    # Legacy translation commands (translating West/East directly)
    elif command == "left":
        robot.direction = "West"
        robot.angle = 270
        new_x = round(robot.x - robot.speed, 2)
    elif command == "right":
        robot.direction = "East"
        robot.angle = 90
        new_x = round(robot.x + robot.speed, 2)

    # Boundary checks
    if new_x < 0 or new_x >= MAP_WIDTH:
        return {"success": False, "message": "Boundary reached"}

    if new_y < 0 or new_y >= MAP_HEIGHT:
        return {"success": False, "message": "Boundary reached"}

    # Obstacle checks (check snapped integer grid coordinate)
    grid_x, grid_y = int(round(new_x)), int(round(new_y))
    if (grid_x, grid_y) in OBSTACLES:
        return {"success": False, "message": "Obstacle detected"}

    robot.x = new_x
    robot.y = new_y
    robot.status = "Moving"
    robot.battery = max(0, robot.battery - 1)

    return {
        "success": True,
        "robot": robot
    }