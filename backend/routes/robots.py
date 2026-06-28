from fastapi import APIRouter, HTTPException

from services.robot_service import get_all_robots, get_robot

router = APIRouter(prefix="/robots", tags=["Robots"])


@router.get("/")
def robots():
    return get_all_robots()


@router.get("/{robot_id}")
def robot(robot_id: int):
    data = get_robot(robot_id)

    if data is None:
        raise HTTPException(status_code=404, detail="Robot not found")

    return data