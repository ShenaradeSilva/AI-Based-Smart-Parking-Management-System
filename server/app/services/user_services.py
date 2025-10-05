import bcrypt
from sqlalchemy.orm import Session
from sqlalchemy import or_
from datetime import datetime
from typing import Optional, List
import base64

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

from ..models.user_model import User, UserRole, UserStatus
from ..models.usersession_model import UserSession
from ..models.vehicle_model import Vehicle
from ..database import get_db
from ..utils.auth_utils import decode_access_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/signin")


# Authentication Helpers
def get_current_user(
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_scheme)
) -> User:
    """
    Get current logged-in user from token.
    Raises 401 if token is invalid or session expired.
    """
    payload = decode_access_token(token)
    if not payload or "sub" not in payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"}
        )

    # Check session
    session = db.query(UserSession).filter(UserSession.token == token).first()
    if not session or session.expiry < datetime.utcnow():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Session expired or invalid",
            headers={"WWW-Authenticate": "Bearer"}
        )

    user_id = int(payload["sub"])
    user = db.query(User).filter(User.user_id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return user


def require_admin(user: User = Depends(get_current_user)) -> User:
    """
    Ensure the current user has admin role.
    Raises 403 if not admin.
    """
    if user.role != UserRole.admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin access required"
        )
    return user


# User Profile & Management
def get_user_by_id(db: Session, user_id: int) -> Optional[User]:
    return db.query(User).filter(User.user_id == user_id).first()


def get_user_profile_with_vehicles(db: Session, user_id: int) -> Optional[dict]:
    """
    Get user profile with vehicle information for frontend.
    """
    user = db.query(User).filter(User.user_id == user_id).first()
    if not user:
        return None

    # Get all vehicles for the user, ordered by creation date
    vehicles = db.query(Vehicle).filter(Vehicle.user_id == user_id).order_by(Vehicle.created_at.asc()).all()

    # Convert profile picture to base64 if it exists
    profile_picture_base64 = None
    if user.profile_picture:
        try:
            profile_picture_base64 = base64.b64encode(user.profile_picture).decode('utf-8')
        except Exception:
            profile_picture_base64 = None

    # Create vehicles list - first vehicle is primary
    vehicles_list = []
    for i, vehicle in enumerate(vehicles):
        # First vehicle (oldest) is always primary
        is_primary = i == 0

        vehicles_list.append({
            "vehicle_id": vehicle.vehicle_id,
            "plate_number": vehicle.plate_number,
            "type": vehicle.type,
            "user_id": vehicle.user_id,
            "created_at": vehicle.created_at,
            "is_primary": is_primary
        })

    # Safely handle enum conversion
    role_value = user.role.value if hasattr(user.role, 'value') else str(user.role)
    status_value = user.status.value if hasattr(user.status, 'value') else str(user.status)

    return {
        "user_id": user.user_id,
        "name": user.name,
        "email": user.email,
        "phone": user.phone,
        "role": role_value,
        "status": status_value,
        "profile_picture": profile_picture_base64,
        "join_date": user.created_at,
        "vehicles": vehicles_list
    }


def update_user_profile(
    db: Session,
    user_id: int,
    name: Optional[str] = None,
    email: Optional[str] = None,
    phone: Optional[str] = None,
    password: Optional[str] = None,
    profile_picture: Optional[bytes] = None,
    remove_picture: bool = False
) -> Optional[User]:
    """
    Update a user's profile fields.
    """
    user = get_user_by_id(db, user_id)
    if not user:
        return None

    if name:
        user.name = name.strip()
    if email:
        user.email = email.strip()
    if phone:
        if phone is not None:
            user.phone = phone.strip()
    if password:
        user.password_hash = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
    if profile_picture:
        user.profile_picture = profile_picture
    if remove_picture:
        user.profile_picture = None

    db.commit()
    db.refresh(user)
    return user


def update_user_profile_picture(
    db: Session,
    user_id: int,
    profile_picture: Optional[bytes] = None,
    remove_picture: bool = False
) -> Optional[User]:
    """
    Update only the profile picture.
    """
    user = get_user_by_id(db, user_id)
    if not user:
        return None

    if profile_picture:
        user.profile_picture = profile_picture
    if remove_picture:
        user.profile_picture = None

    db.commit()
    db.refresh(user)
    return user


def get_all_users(db: Session, search: Optional[str] = None) -> List[User]:
    """
    Return a list of users, optionally filtered by name or email.
    """
    query = db.query(User)
    if search:
        query = query.filter(
            or_(
                User.name.ilike(f"%{search}%"),
                User.email.ilike(f"%{search}%")
            )
        )
    return query.all()


def create_user(
    db: Session,
    name: str,
    email: str,
    password: str,
    role: UserRole,
    phone: Optional[str] = None
) -> User:
    """
    Create a new user with hashed password.
    """
    hashed_password = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
    new_user = User(
        name=name.strip(),
        email=email.strip(),
        password_hash=hashed_password,
        phone=phone.strip() if phone else None,
        role=role,
        status=UserStatus.active
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


def admin_update_user(
    db: Session,
    user_id: int,
    role: Optional[UserRole] = None,
    status: Optional[UserStatus] = None
) -> Optional[User]:
    """
    Admin-only: Update user's role or status.
    """
    user = get_user_by_id(db, user_id)
    if not user:
        return None
    if role:
        user.role = role
    if status:
        user.status = status

    db.commit()
    db.refresh(user)
    return user


def delete_user(db: Session, user_id: int) -> bool:
    """
    Delete a user.
    """
    user = get_user_by_id(db, user_id)
    if not user:
        return False
    db.delete(user)
    db.commit()
    return True


def toggle_user_status(db: Session, user_id: int) -> Optional[User]:
    """
    Toggle user's active/inactive status.
    """
    user = get_user_by_id(db, user_id)
    if not user:
        return None

    user.status = UserStatus.inactive if user.status == UserStatus.active else UserStatus.active
    db.commit()
    db.refresh(user)
    return user
