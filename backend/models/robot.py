from pydantic import BaseModel
from typing import Optional


class Robot(BaseModel):
    id: str
    name: str
    model_type: str

    x: float
    y: float
    angle: int

    direction: str

    battery: int
    speed: float

    status: str
    mode: str

    is_online: bool

    current_task: str

    map_name: str

    # Auto Navigation
    start_x: Optional[float] = None
    start_y: Optional[float] = None

    destination_x: Optional[float] = None
    destination_y: Optional[float] = None

    auto_navigation: bool = False
    task_paused: bool = False

    previous_mode: Optional[str] = None