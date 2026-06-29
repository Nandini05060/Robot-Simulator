import asyncio
from typing import Union

from services.robot_service import get_robot
from services.telemetry_service import build_telemetry
from core.websocket_manager import manager


async def start_navigation(
    robot_id: Union[int, str],
    start_x: float,
    start_y: float,
    destination_x: float,
    destination_y: float,
):

    robot = get_robot(robot_id)

    if robot is None:
        return {
            "success": False,
            "message": "Robot not found"
        }

    # Place robot at selected start point
    robot.x = start_x
    robot.y = start_y

    robot.start_x = start_x
    robot.start_y = start_y

    robot.destination_x = destination_x
    robot.destination_y = destination_y

    robot.auto_navigation = True
    robot.mode = "Auto"
    robot.status = "Navigating"

    # Automatic movement loop
    while robot.auto_navigation:

        # Move in X direction
        if robot.x < robot.destination_x:
            robot.x += robot.speed

        elif robot.x > robot.destination_x:
            robot.x -= robot.speed

        # Move in Y direction
        elif robot.y < robot.destination_y:
            robot.y += robot.speed

        elif robot.y > robot.destination_y:
            robot.y -= robot.speed

        # Send telemetry every movement
        await manager.broadcast(
            build_telemetry(robot)
        )

        # Destination reached
        if (
            robot.x == robot.destination_x
            and robot.y == robot.destination_y
        ):
            robot.auto_navigation = False
            robot.status = "Idle"
            robot.mode = "Manual"
            break

        await asyncio.sleep(0.2)

    return {
        "success": True,
        "robot": robot
    }


def stop_navigation(robot_id: Union[int, str]):

    robot = get_robot(robot_id)

    if robot is None:
        return

    robot.auto_navigation = False
    robot.status = "Manual"
    robot.mode = "Manual"