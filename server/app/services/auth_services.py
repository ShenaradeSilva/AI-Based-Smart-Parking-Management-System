# services/auth_services.py
import bcrypt
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
import random

from ..models.user_model import User, UserRole, UserStatus
from ..models.usersession_model import UserSession
from ..models.vehicle_model import Vehicle
from ..utils.email_service import send_welcome_email_driver, send_welcome_email_admin, send_password_reset_code, send_password_reset_success
from ..utils.auth_utils import create_access_token
from ..config import ACCESS_TOKEN_EXPIRE_MINUTES

# In-memory store for password reset codes
reset_codes = {}  # { email: { "code": "1234", "expires_at": datetime } }


def create_driver(db: Session, user_data):
    """
    Create a new driver and their vehicle.
    """
    email = user_data.email.strip().lower()

    # Check if email already exists
    existing_user = db.query(User).filter(func.lower(User.email) == email).first()
    if existing_user:
        return None  # email already exists

    # Hash password
    if not user_data.password:
        raise ValueError("Password is required for driver account")

    hashed_password = bcrypt.hashpw(
        user_data.password.encode("utf-8"), bcrypt.gensalt()
    ).decode("utf-8")

    new_driver = User(
        name=user_data.name.strip(),
        email=email,
        password_hash=hashed_password,
        phone=user_data.phone.strip() if user_data.phone else None,
        role=UserRole.driver,
        status=UserStatus.active,
    )

    db.add(new_driver)
    db.commit()
    db.refresh(new_driver)

    # Add vehicle
    if user_data.vehicle_number and user_data.vehicle_type:
        vehicle = Vehicle(
            plate_number=user_data.vehicle_number.strip(),
            type=user_data.vehicle_type.strip(),
            user_id=new_driver.user_id,
        )
        db.add(vehicle)
        db.commit()
        db.refresh(vehicle)

    # Send driver welcome email
    send_welcome_email_driver(
        name=user_data.name.strip(),
        email=email,
        phone=user_data.phone.strip() if user_data.phone else "N/A",
        vehicle_number=user_data.vehicle_number.strip() if user_data.vehicle_number else "N/A"
    )

    return new_driver


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


def login_user(db: Session, email: str, password: str, platform: str = "mobile"):
    """
    Authenticate a user (driver or admin)
    :param platform: "mobile" for drivers, "web" for admins
    """
    email = email.strip().lower()
    user = db.query(User).filter(func.lower(User.email) == email).first()

    # Reject if not found or inactive
    if not user or user.status != UserStatus.active:
        return None

    # Enforce platform access
    if platform == "web" and user.role != UserRole.admin:
        return None
    if platform == "mobile" and user.role != UserRole.driver:
        return None

    # Verify password
    if not bcrypt.checkpw(password.encode("utf-8"), user.password_hash.encode("utf-8")):
        return None

    # Generate JWT token
    token = create_access_token({"sub": str(user.user_id), "role": user.role})

    # Create new session
    expiry = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    session = UserSession(token=token, expiry=expiry, user_id=user.user_id)
    db.add(session)
    db.commit()
    db.refresh(session)

    return token, user


# Password Reset
def send_reset_code(user: User):
    """
    Generate and send a 4-digit reset code (expires in 10 mins).
    """
    code = f"{random.randint(1000, 9999)}"
    expires_at = datetime.utcnow() + timedelta(minutes=10)
    reset_codes[user.email] = {"code": code, "expires_at": expires_at}

    send_password_reset_code(user.name, user.email, code)
    return True


def verify_reset_code(email: str, code: str):
    """
    Check if reset code is valid and not expired.
    """
    record = reset_codes.get(email)
    if not record:
        return False, "No reset request found"

    if record["code"] != code:
        return False, "Invalid verification code"

    if record["expires_at"] < datetime.utcnow():
        reset_codes.pop(email, None)
        return False, "Code expired"

    return True, None


def reset_password(db: Session, user: User, new_password: str):
    """
    Reset password after successful code verification.
    """
    hashed = bcrypt.hashpw(new_password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
    user.password_hash = hashed
    db.commit()

    reset_codes.pop(user.email, None)
    send_password_reset_success(user.name, user.email)

    return True
