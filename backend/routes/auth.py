from fastapi import APIRouter, HTTPException, Header, Request

from models.user import UserLogin
from services.auth_service import authenticate_user
from services.activity_logger import log_activity
from core.jwt_handler import create_access_token, verify_access_token

router = APIRouter()


@router.post("/login")
def login(user: UserLogin, request: Request):

    username_lower = user.username.strip().lower()
    role = "Admin" if ("admin" in username_lower) else "Operator"
    user_agent = request.headers.get("user-agent", "Unknown Client")

    authenticated_user = authenticate_user(
        user.username,
        user.password
    )

    if authenticated_user is None:
        log_activity(
            user.username,
            "LOGIN_FAILED",
            f"Failed login attempt | Role={role} | Client={user_agent} | Reason=Invalid credentials"
        )
        raise HTTPException(
            status_code=401,
            detail="Invalid username or password"
        )

    access_token = create_access_token(
        {"sub": authenticated_user["username"]}
    )

    log_activity(
        authenticated_user["username"],
        "LOGIN_SUCCESS",
        f"Login successful | Role={role} | Client={user_agent}"
    )

    return {
        "access_token": access_token,
        "token_type": "bearer"
    }


@router.post("/logout")
def logout(request: Request, authorization: str = Header(..., alias="Authorization")):

    if authorization.startswith("Bearer "):
        token = authorization[7:]
    else:
        token = authorization

    username = verify_access_token(token)

    if username is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired token"
        )

    username_lower = username.strip().lower()
    role = "Admin" if ("admin" in username_lower) else "Operator"
    user_agent = request.headers.get("user-agent", "Unknown Client")

    log_activity(
        username,
        "LOGOUT",
        f"User logged out | Role={role} | Client={user_agent}"
    )

    return {
        "message": "Logout successful"
    }