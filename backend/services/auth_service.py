from data.users import users


def authenticate_user(username: str, password: str):
    for user in users:
        if (
            user["username"] == username
            and user["password"] == password
        ):
            return user

    return None