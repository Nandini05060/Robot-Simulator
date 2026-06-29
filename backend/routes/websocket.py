from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import json
import asyncio
from core.websocket_manager import manager
from core.jwt_handler import verify_access_token
from services.simulation_service import move_robot
from services.telemetry_service import build_telemetry
from services.delivery_service import (
    start_delivery,
    stop_delivery
)

from services.navigation_service import (
    start_navigation,
    stop_navigation
)


router = APIRouter()


@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):

    token = websocket.query_params.get("token")

    username = verify_access_token(token)

    if username is None:
        await websocket.close(code=1008)
        return

    await manager.connect(websocket)

    try:
        while True:

            data = await websocket.receive_text()
            

            message = json.loads(data)

            message_type = message.get("type")

            robot_id = message.get("robot_id")

            payload = message.get("payload", {})

            if message_type == "MOVE":

                result = move_robot(
                    robot_id,
                    payload.get("command")
                )

                if not result["success"]:
                    await websocket.send_json(result)
                    continue

                robot = result["robot"]

                await manager.broadcast(
                    build_telemetry(robot)
                )

            elif message_type == "START_DELIVERY":

                result = start_delivery(
                    robot_id,
                    payload
                )

                if not result["success"]:
                    await websocket.send_json(result)
                    continue

                await manager.broadcast(
                    build_telemetry(result["robot"])
                )


            elif message_type == "STOP_DELIVERY":

                result = stop_delivery(robot_id)

                if not result["success"]:
                    await websocket.send_json(result)
                    continue

                await manager.broadcast(
                    build_telemetry(result["robot"])
                )

            elif message_type == "START_AUTO":

                asyncio.create_task(
                    start_navigation(
                        robot_id,
                        payload.get("start_x"),
                        payload.get("start_y"),
                        payload.get("destination_x"),
                        payload.get("destination_y")
                    )
                )

                await websocket.send_json({
                    "type": "AUTO_STARTED",
                    "robot_id": robot_id
                })

            elif message_type == "STOP_AUTO":

                stop_navigation(robot_id)

                await websocket.send_json({
                    "type": "AUTO_STOPPED",
                    "robot_id": robot_id
                })
            else:

                await websocket.send_json({
                    "type": "ERROR",
                    "message": "Unknown event type"
                })

    except WebSocketDisconnect:
        manager.disconnect(websocket)
        print(f"{username} disconnected")