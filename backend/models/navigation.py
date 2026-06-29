from pydantic import BaseModel


class NavigationRequest(BaseModel):
    robot_id: int

    start_x: float
    start_y: float

    destination_x: float
    destination_y: float