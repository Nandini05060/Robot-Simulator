from fastapi import FastAPI
from routes.robots import router as robot_router
from routes.auth import router as auth_router
from routes.websocket import router as websocket_router
from routes.dashboard import router as dashboard_router

app = FastAPI(
    title="Robot Simulator Backend",
    version="1.0.0"
)

app.include_router(auth_router)
app.include_router(websocket_router)


@app.get("/")
def home():
    return {
        "message": "Robot Simulator Backend Running"
    }

app.include_router(robot_router)

app.include_router(dashboard_router)