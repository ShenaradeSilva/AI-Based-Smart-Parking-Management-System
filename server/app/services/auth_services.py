# services/auth_services.py
import bcrypt
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
import random

from ..models.user_model import User, UserRole, UserStatus
from ..models.usersession_model import UserSession
from ..utils.email_utils import send_email, send_verification_email
from ..utils.auth_utils import create_access_token
from ..config import ACCESS_TOKEN_EXPIRE_MINUTES

# In-memory store for password reset codes
reset_codes = {}  # { email: { "code": "1234", "expires_at": datetime } }


def create_admin(db: Session, user_data):
    """
    Create a new admin user from UserCreate schema.
    This forces role = admin regardless of what frontend sends.
    """
    email = user_data.email.strip().lower()

    # Check if email already exists
    existing_user = db.query(User).filter(func.lower(User.email) == email).first()
    if existing_user:
        return None  # email already exists

    # Hash password (required)
    if not user_data.password:
        raise ValueError("Password is required for admin account")

    hashed_password = bcrypt.hashpw(
        user_data.password.encode("utf-8"), bcrypt.gensalt()
    ).decode("utf-8")

    new_admin = User(
        name=user_data.name.strip(),
        email=email,
        password_hash=hashed_password,
        phone=user_data.phone.strip() if user_data.phone else None,  # updated
        role=UserRole.admin,  # force admin role
        status=UserStatus.active,  # ensure admin is active
    )

    db.add(new_admin)
    db.commit()
    db.refresh(new_admin)

    # Send admin welcome email
    send_welcome_email_admin(user_data.name.strip(), email)

    return new_admin


def login_admin(db: Session, email: str, password: str):
    """
    Authenticate admin user only.
    Returns (token, user) if successful, None if invalid or not admin.
    """
    email = email.strip().lower()
    user = db.query(User).filter(func.lower(User.email) == email).first()

    # reject if not found, not admin, or inactive
    if not user or user.role != UserRole.admin or user.status != UserStatus.active:
        return None

    # check password
    if not bcrypt.checkpw(password.encode("utf-8"), user.password_hash.encode("utf-8")):
        return None

    # generate JWT token
    token = create_access_token({"sub": str(user.user_id), "role": user.role})

    # remove old sessions
    db.query(UserSession).filter(UserSession.user_id == user.user_id).delete()

    # create new session
    expiry = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    session = UserSession(token=token, expiry=expiry, user_id=user.user_id)
    db.add(session)
    db.commit()
    db.refresh(session)

    return token, user


# Password Reset
def send_reset_code(user: User):
    """
    Generate a 4-digit code, store temporarily, and send via email.
    Expires in 10 minutes.
    """
    code = f"{random.randint(1000, 9999)}"
    expires_at = datetime.utcnow() + timedelta(minutes=10)
    reset_codes[user.email] = {"code": code, "expires_at": expires_at}

    # Send password reset code email
    send_password_reset_code(user.name, user.email, code)


def verify_reset_code(email: str, code: str):
    """
    Verify if the reset code is valid and not expired.
    """
    record = reset_codes.get(email)
    if not record:
        return False, "No reset request found"

    if record["code"] != code:
        return False, "Invalid verification code"

    if record["expires_at"] < datetime.utcnow():
        reset_codes.pop(email)
        return False, "Code expired"

    return True, None


def reset_password(db: Session, user: User, new_password: str):
    """
    Reset the user's password and remove the used code.
    """
    hashed = bcrypt.hashpw(new_password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
    user.password_hash = hashed
    db.commit()
    reset_codes.pop(user.email, None)

    # Send password reset success email
    send_password_reset_success(user.name, user.email)
