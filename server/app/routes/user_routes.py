from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Query, Body, Form
from sqlalchemy.orm import Session
from typing import List, Optional

from ..schemas.user_schema import UserProfileOut, UserRole, UserCreate
from ..models.user_model import User, UserStatus
from ..services.user_services import (
    get_current_user,
    require_admin,
    get_user_by_id,
    update_user_profile,
    admin_update_user,
    get_all_users,
    delete_user,
    create_user,
    toggle_user_status
)
from ..services.notification_services import create_notification
from ..database import get_db

router = APIRouter(prefix="/api/users", tags=["Users"])


# PROFILE ROUTES
@router.get("/profile", response_model=UserProfileOut)
def get_profile(current_user: User = Depends(get_current_user)):
    """
    Get current user profile including vehicle info.
    """
    # Get primary vehicle (assume first one for now)
    primary_vehicle = current_user.vehicles[0] if current_user.vehicles else None

    return UserProfileOut.from_orm(current_user).copy(update={
        "vehicle_number": primary_vehicle.plate_number if primary_vehicle else None,
        "vehicle_type": primary_vehicle.type if primary_vehicle else None
    })


@router.put("/profile/update", response_model=UserProfileOut)
async def update_profile(
    name: Optional[str] = Form(None),
    email: Optional[str] = Form(None),
    phone: Optional[str] = Form(None),
    vehicle_number: Optional[str] = Form(None),
    vehicle_type: Optional[str] = Form(None),
    password: Optional[str] = Form(None),
    profile_picture: Optional[UploadFile] = File(None),
    remove_picture: bool = Form(False),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Update current user profile.
    """
    # Update user
    updated_user = update_user_profile(
        db, current_user.user_id,
        name=name,
        email=email,
        mobile=phone,  # will handle below
        password=password,
        profile_picture=await profile_picture.read() if profile_picture else None,
        remove_picture=remove_picture
    )

    if not updated_user:
        raise HTTPException(status_code=400, detail="Failed to update profile")

    # Update vehicle
    if vehicle_number is not None or vehicle_type is not None:
        if current_user.vehicles:
            # Update first vehicle
            v = current_user.vehicles[0]
            if vehicle_number is not None:
                v.plate_number = vehicle_number
            if vehicle_type is not None:
                v.type = vehicle_type
        elif vehicle_number and vehicle_type:
            # Create new vehicle
            from ..models.vehicle_model import Vehicle
            new_v = Vehicle(
                user_id=current_user.user_id,
                plate_number=vehicle_number,
                type=vehicle_type
            )
            db.add(new_v)

        db.commit()
        db.refresh(current_user)

    # Re-fetch for response
    primary_vehicle = current_user.vehicles[0] if current_user.vehicles else None

    return UserProfileOut.from_orm(current_user).copy(update={
        "vehicle_number": primary_vehicle.plate_number if primary_vehicle else None,
        "vehicle_type": primary_vehicle.type if primary_vehicle else None
    })


# ADMIN USER MANAGEMENT
@router.get("/", response_model=List[UserProfileOut])
def list_users(
    search: Optional[str] = Query(None, description="Search by name or email"),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
):
    """
    List all users (admin only). Optional search.
    """
    users = get_all_users(db, search)
    return [UserProfileOut.from_orm(u) for u in users]


@router.post("/", response_model=UserProfileOut, status_code=status.HTTP_201_CREATED)
def add_user(
    user_data: UserCreate = Body(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
):
    """
    Admin creates a new user.
    """
    existing_users = get_all_users(db, search=user_data.email)
    if any(u.email == user_data.email for u in existing_users):
        raise HTTPException(status_code=400, detail="Email already exists")

    new_user = create_user(
        db=db,
        name=user_data.name,
        email=user_data.email,
        password=user_data.password,
        phone=user_data.phone,
        role=user_data.role
    )

    create_notification(
        db,
        f"Admin {current_user.name} created a new user account for {new_user.name}",
        "info",
        user_id=new_user.user_id
    )
    return UserProfileOut.from_orm(new_user)


@router.put("/{user_id}/update", response_model=UserProfileOut)
def edit_user(
    user_id: int,
    role: Optional[UserRole] = None,
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
):
    """
    Admin updates another user's role or status.
    """
    status_enum: Optional[UserStatus] = None
    if status:
        try:
            status_enum = UserStatus[status.lower()]
        except KeyError:
            raise HTTPException(status_code=400, detail="Invalid status value")

    updated_user = admin_update_user(db, user_id, role=role, status=status_enum)
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found or update failed")

    create_notification(
        db,
        f"Your account has been updated by admin {current_user.name}",
        "info",
        user_id=updated_user.user_id
    )
    return UserProfileOut.from_orm(updated_user)


@router.put("/{user_id}/toggle-status", response_model=UserProfileOut)
def toggle_status(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
):
    """
    Admin toggles a user's active/inactive status.
    """
    updated_user = toggle_user_status(db, user_id)
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found or failed to update status")

    create_notification(
        db,
        f"Your account status was changed by admin {current_user.name}",
        "info",
        user_id=updated_user.user_id
    )
    return UserProfileOut.from_orm(updated_user)


@router.delete("/{user_id}/delete", status_code=status.HTTP_204_NO_CONTENT)
def remove_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
):
    """
    Admin deletes a user account.
    """
    user = get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found or deletion failed")

    success = delete_user(db, user_id)
    if not success:
        raise HTTPException(status_code=404, detail="User not found or deletion failed")

    create_notification(
        db,
        f"Your account was deleted by admin {current_user.name}",
        "cancellation",
        user_id=user_id
    )
    return None
