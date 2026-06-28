# Robot Simulator Backend

Backend for the Robot Simulator application built using **FastAPI**, **JWT Authentication**, and **WebSockets** for real-time robot communication.

## Features

- JWT Authentication
- WebSocket-based Robot Communication
- Robot Movement
- Robot Rotation
- Multiple Robots
- Dashboard API
- Real-Time Telemetry
- Delivery Mode
- Battery Simulation
- Boundary Detection
- Obstacle Detection

## Tech Stack

- Python 3.x
- FastAPI
- WebSockets
- Pydantic
- python-jose (JWT)
- Uvicorn

## Project Structure

```
backend/
│
├── app.py
├── core/
├── data/
├── models/
├── routes/
├── services/
├── utils/
└── requirements.txt
```

## Installation

Clone the repository:

```bash
git clone https://github.com/Risheekmahajan/robot-simulator-backend.git
```

Go to the project folder:

```bash
cd robot-simulator-backend
```

Create a virtual environment:

```bash
python -m venv venv
```

Activate it:

### Windows

```bash
venv\Scripts\activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run the server:

```bash
uvicorn app:app --reload
```

Server runs at:

```
http://127.0.0.1:8000
```

Swagger Documentation:

```
http://127.0.0.1:8000/docs
```

---

# Authentication

## Login

**POST**

```
/login
```

Request:

```json
{
  "username": "admin",
  "password": "admin123"
}
```

---

# Robot APIs

## Get Robots

```
GET /robots
```

## Dashboard

```
GET /dashboard
```

---

# WebSocket

Connect to:

```
ws://127.0.0.1:8000/ws?token=<JWT_TOKEN>
```

Example message:

```json
{
  "type": "MOVE",
  "robot_id": 1,
  "payload": {
    "command": "forward"
  }
}
```

Example response:

```json
{
  "type": "TELEMETRY",
  "robot_id": 1,
  "position": {
    "x": 5,
    "y": 4
  },
  "battery": 99,
  "status": "Moving"
}
```

---

# Developed By

**Risheek Mahajan**

Backend Developer – Robot Simulator Project