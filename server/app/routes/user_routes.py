from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Query, Body
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordBearer
from typing import List, Optional
from datetime import datetime
from fastapi import Form

from ..schemas.user_schema import UserProfileOut, UserRole, UserCreate
from ..services.user_services import (
    get_user_by_id,
    update_user_profile,
    admin_update_user,
    get_all_users,
    delete_user,
    create_user
)
from ..services.notification_services import create_notification
from ..models.usersession_model import UserSession
from ..models.user_model import User
from ..database import get_db
from ..utils.auth_utils import decode_access_token

router = APIRouter(prefix="/api/users", tags=["Users"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/signin")


# Dependency to get current logged-in user
def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    payload = decode_access_token(token)
    if not payload or "sub" not in payload:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    # Check if session
    # exists and not expired
    session = db.query(UserSession).filter(UserSession.token == token).first()
    if not session or session.expiry < datetime.utcnow():
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Session expired or invalid")

    user_id = int(payload["sub"])
    user = get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user


# Admin access check
def require_admin(current_user=Depends(get_current_user)):
    if current_user.role != UserRole.admin:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin access required")
    return current_user


# Get Profile
# ✅ Profile route - this should create /users/profile
@router.get("/profile", response_model=UserProfileOut)
def get_profile(current_user=Depends(get_current_user)):
    print(f"✅ Profile route hit for user: {current_user.name}")
    return current_user


# Update Profile (self)
@router.put("/profile", response_model=UserProfileOut)
async def update_profile(
    name: Optional[str] = Form(None),
    email: Optional[str] = Form(None),
    phone: Optional[str] = Form(None),
    password: Optional[str] = Form(None),
    profile_picture: Optional[UploadFile] = File(None),
    remove_picture: bool = Form(False),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user)
):
    picture_data = await profile_picture.read() if profile_picture else None

    updated_user = update_user_profile(
        db,
        current_user.user_id,
        name=name,
        email=email,
        mobile=phone,
        password=password,
        profile_picture=picture_data,
        remove_picture=remove_picture
    )

    if not updated_user:
        raise HTTPException(status_code=400, detail="Failed to update profile")

    create_notification(
        db,
        "Your profile was updated successfully",
        "info",
        user_id=current_user.user_id
    )

    return updated_user

# User Management (Admin)
# Get all users with optional search
@router.get("/", response_model=List[UserProfileOut])
def list_users(
    search: Optional[str] = Query(None, description="Search by name or email"),
    db: Session = Depends(get_db),
    current_user=Depends(require_admin)
):
    return get_all_users(db, search)


# Add new user (admin)
@router.post("/", response_model=UserProfileOut, status_code=status.HTTP_201_CREATED)
def add_user(
    user_data: UserCreate = Body(...),
    db: Session = Depends(get_db),
    current_user=Depends(require_admin)
):
    # Check if email already exists
    existing_users = get_all_users(db, search=user_data.email)
    if any(u.email == user_data.email for u in existing_users):
        raise HTTPException(status_code=400, detail="Email already exists")

    new_user = create_user(
        db,
        name=user_data.name,
        email=user_data.email,
        phone=user_data.phone,
        role=user_data.role
    )

    if not new_user:
        raise HTTPException(status_code=400, detail="Failed to create user")

    # Notification
    create_notification(
        db,
        f"Admin {current_user.name} created a new user account for {new_user.name}",
        "info",
        user_id=new_user.user_id
    )

    return new_user


# Update user (admin) - only role and status
@router.put("/{user_id}", response_model=UserProfileOut)
def edit_user(
    user_id: int,
    role: Optional[UserRole] = None,
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user=Depends(require_admin)
):
    updated_user = admin_update_user(db, user_id, role=role, status=status)
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found or update failed")

    # Notification
    create_notification(
        db,
        f"Your account has been updated by admin {current_user.name}",
        "info",
        user_id=updated_user.user_id
    )

    return updated_user


# Delete user (admin)
@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_user(user_id: int, db: Session = Depends(get_db), current_user=Depends(require_admin)):
    user = get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found or deletion failed")

    success = delete_user(db, user_id)
    if not success:
        raise HTTPException(status_code=404, detail="User not found or deletion failed")

    # Notification
    create_notification(
        db,
        f"Your account was deleted by admin {current_user.name}",
        "cancellation",
        user_id=user_id
    )

    return None
