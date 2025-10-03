import bcrypt
from sqlalchemy.orm import Session
from sqlalchemy import or_
from datetime import datetime
from typing import Optional, List

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

from ..models.user_model import User, UserRole, UserStatus
from ..models.usersession_model import UserSession
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


def update_user_profile(
    db: Session,
    user_id: int,
    name: Optional[str] = None,
    email: Optional[str] = None,
    mobile: Optional[str] = None,
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
    if mobile:
        if mobile is not None:
            user.phone = mobile.strip()
    if password:
        user.password_hash = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
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
