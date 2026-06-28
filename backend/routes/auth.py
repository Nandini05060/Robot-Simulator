from fastapi import APIRouter, HTTPException

from models.user import UserLogin
from services.auth_service import authenticate_user
from core.jwt_handler import create_access_token

router = APIRouter()


@router.post("/login")
def login(user: UserLogin):

    authenticated_user = authenticate_user(
        user.username,
        user.password
    )

    if authenticated_user is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid username or password"
        )

    access_token = create_access_token(
        {"sub": authenticated_user["username"]}
    )

    return {
        "access_token": access_token,
        "token_type": "bearer"
    }