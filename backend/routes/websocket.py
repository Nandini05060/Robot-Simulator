from fastapi import APIRouter, WebSocket, WebSocketDisconnect
import json
from core.websocket_manager import manager
from core.jwt_handler import verify_access_token
from services.simulation_service import move_robot
from services.telemetry_service import build_telemetry
from services.delivery_service import (
    start_delivery,
    stop_delivery
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
                    await manager.broadcast(result)
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
            else:

                await websocket.send_json({
                    "type": "ERROR",
                    "message": "Unknown event type"
                })

    except WebSocketDisconnect:
        manager.disconnect(websocket)
        print(f"{username} disconnected")