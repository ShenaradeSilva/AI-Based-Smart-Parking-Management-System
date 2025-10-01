import jwt
from datetime import datetime, timedelta
from app.config import JWT_SECRET, ACCESS_TOKEN_EXPIRE_MINUTES
from jwt import PyJWTError


def create_access_token(data: dict, expires_delta: timedelta = None):
    """
    Creates a JWT token with an optional expiry.
    """
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, JWT_SECRET, algorithm="HS256")


def decode_access_token(token: str):
    """
    Decodes a JWT token and returns the payload.
    Raises an exception if token is invalid or expired.
    """
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
        return payload
    except PyJWTError:
        return None
