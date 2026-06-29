from pydantic import BaseModel
from typing import Union


class NavigationRequest(BaseModel):
    robot_id: Union[int, str]

    start_x: float
    start_y: float

    destination_x: float
    destination_y: float