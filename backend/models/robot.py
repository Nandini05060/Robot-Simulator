from pydantic import BaseModel


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