from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Query, Body, Form
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List, Optional
import bcrypt
import secrets
import base64

from ..schemas.user_schema import UserProfileOut, UserRole, UserCreate, UserCreateResponse
from ..schemas.vehicle_schema import VehicleCreate
from ..models.user_model import User, UserStatus
from ..services.user_services import (
    get_current_user,
    require_admin,
    get_user_by_id,
    get_user_profile_with_vehicles,
    update_user_profile,
    update_user_profile_picture,
    admin_update_user,
    get_all_users,
    delete_user,
    create_user,
    toggle_user_status
)
from ..services.vehicle_services import create_vehicle, delete_vehicle, get_vehicle_by_plate
from ..services.notification_services import create_notification
from ..database import get_db

router = APIRouter(prefix="/api/users", tags=["Users"])


# PROFILE ROUTES
@router.get("/profile", response_model=UserProfileOut)
def get_profile(
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Get current user profile including vehicle info.
    """
    try:
        profile_data = get_user_profile_with_vehicles(db, current_user.user_id)
        if not profile_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile not found"
            )

        # Use the custom from_orm if available, otherwise create directly
        try:
            return UserProfileOut.from_orm(current_user)
        except:
            return UserProfileOut(**profile_data)

    except Exception as e:
        print(f"Profile route error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to load profile: {str(e)}"
        )


@router.put("/profile/update")
async def update_profile(
        name: Optional[str] = Form(None),
        email: Optional[str] = Form(None),
        phone: Optional[str] = Form(None),
        password: Optional[str] = Form(None),
        profile_picture: Optional[UploadFile] = File(None),
        profile_picture_base64: Optional[str] = Form(None),  # For web
        remove_picture: bool = Form(False),
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Update current user profile.
    """
    try:
        # Handle profile picture
        profile_picture_bytes = None

        if profile_picture_base64:
            # Web base64 image
            if profile_picture_base64.startswith('data:'):
                profile_picture_base64 = profile_picture_base64.split(',')[1]
            profile_picture_bytes = base64.b64decode(profile_picture_base64)
        elif profile_picture:
            # Mobile file upload
            profile_picture_bytes = await profile_picture.read()

        # Validate file size if there's a picture
        if profile_picture_bytes and len(profile_picture_bytes) > 5 * 1024 * 1024:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Profile picture too large. Maximum size is 5MB."
            )

        # Update user profile
        updated_user = update_user_profile(
            db=db,
            user_id=current_user.user_id,
            name=name,
            email=email,
            phone=phone,
            password=password,
            profile_picture=profile_picture_bytes,
            remove_picture=remove_picture
        )

        if not updated_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to update profile"
            )

        # Get updated profile data
        profile_data = get_user_profile_with_vehicles(db, current_user.user_id)

        return {
            "success": True,
            "data": UserProfileOut(**profile_data),
            "message": "Profile updated successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update profile: {str(e)}"
        )


@router.post("/profile/vehicles-add")
async def add_vehicle_to_profile(
        plate_number: str = Form(...),
        vehicle_type: str = Form(...),
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Add a new vehicle to user's profile.
    """
    try:
        # Check if vehicle already exists for any user
        existing_vehicle = get_vehicle_by_plate(plate_number, db)
        if existing_vehicle:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Vehicle with this plate number already exists"
            )

        # Create vehicle using existing vehicle service
        vehicle_data = VehicleCreate(
            plate_number=plate_number,
            type=vehicle_type,
            user_id=current_user.user_id
        )

        new_vehicle = create_vehicle(vehicle_data, db)

        # Get updated profile
        profile_data = get_user_profile_with_vehicles(db, current_user.user_id)

        return {
            "success": True,
            "data": UserProfileOut(**profile_data),
            "message": "Vehicle added successfully"
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to add vehicle: {str(e)}"
        )


@router.delete("/profile/vehicles-remove/{vehicle_id}")
async def remove_vehicle_from_profile(
        vehicle_id: int,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Remove a vehicle from user's profile.
    """
    try:
        # Use existing vehicle service to delete
        delete_vehicle(vehicle_id, db)

        # Get updated profile
        profile_data = get_user_profile_with_vehicles(db, current_user.user_id)

        return {
            "success": True,
            "data": UserProfileOut(**profile_data),
            "message": "Vehicle removed successfully"
        }

    except HTTPException as he:
        if he.status_code == 404:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Vehicle not found"
            )
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to remove vehicle: {str(e)}"
        )


@router.put("/profile/update-picture")
async def update_profile_picture(
        profile_picture: UploadFile = File(...),
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Update only the profile picture.
    """
    try:
        profile_picture_bytes = await profile_picture.read()

        # Validate file size (max 5MB)
        if len(profile_picture_bytes) > 5 * 1024 * 1024:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Profile picture too large. Maximum size is 5MB."
            )

        # Validate file type
        if profile_picture.content_type not in ['image/jpeg', 'image/png', 'image/jpg']:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid file type. Only JPEG and PNG are allowed."
            )

        updated_user = update_user_profile_picture(
            db=db,
            user_id=current_user.user_id,
            profile_picture=profile_picture_bytes
        )

        if not updated_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to update profile picture"
            )

        # Convert to base64 for response
        profile_picture_base64 = base64.b64encode(profile_picture_bytes).decode('utf-8')

        return {
            "success": True,
            "message": "Profile picture updated successfully",
            "profile_picture": profile_picture_base64
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update profile picture: {str(e)}"
        )


@router.put("/profile/update-picture-base64")
async def update_profile_picture_base64(
        profile_picture_base64: str = Form(...),
        mime_type: str = Form("image/jpeg"),
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Update profile picture using base64 (for web).
    """
    try:
        # Remove data URL prefix if present
        if profile_picture_base64.startswith('data:'):
            profile_picture_base64 = profile_picture_base64.split(',')[1]

        # Decode base64 to bytes
        profile_picture_bytes = base64.b64decode(profile_picture_base64)

        # Validate file size (max 5MB)
        if len(profile_picture_bytes) > 5 * 1024 * 1024:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Profile picture too large. Maximum size is 5MB."
            )

        updated_user = update_user_profile_picture(
            db=db,
            user_id=current_user.user_id,
            profile_picture=profile_picture_bytes
        )

        if not updated_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to update profile picture"
            )

        return {
            "success": True,
            "message": "Profile picture updated successfully",
            "profile_picture": profile_picture_base64
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update profile picture: {str(e)}"
        )


@router.delete("/profile/delete-picture")
async def remove_profile_picture(
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    """
    Remove profile picture.
    """
    try:
        updated_user = update_user_profile_picture(
            db=db,
            user_id=current_user.user_id,
            remove_picture=True
        )

        if not updated_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to remove profile picture"
            )

        return {
            "success": True,
            "message": "Profile picture removed successfully"
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to remove profile picture: {str(e)}"
        )


# ADMIN USER MANAGEMENT
@router.get("/getusers", response_model=List[UserProfileOut])
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


@router.post("/add", response_model=UserCreateResponse)
def add_user(
    user_data: UserCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_admin)
):
    """
    Admin creates a new user. Auto-generates password if none is provided.
    Returns 200 in the response body.
    """
    # Check if email already exists
    existing_users = get_all_users(db, search=user_data.email)
    if any(u.email == user_data.email for u in existing_users):
        raise HTTPException(status_code=400, detail="Email already exists")

    # Use provided password or generate a secure random one
    password = user_data.password or secrets.token_urlsafe(10)

    # Hash the password
    hashed_password = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")

    # Create user
    new_user = create_user(
        db=db,
        name=user_data.name,
        email=user_data.email,
        password=hashed_password,
        phone=user_data.phone,
        role=user_data.role
    )

    # Create notification for the new user
    create_notification(
        db,
        f"Admin {current_user.name} created a new user account for {new_user.name}",
        "info",
        user_id=new_user.user_id
    )

    # Return wrapped response
    return UserCreateResponse(
        status=200,
        success=True,
        message=f"User {new_user.name} created successfully",
        data=UserProfileOut.from_orm(new_user)
    )


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


@router.delete("/{user_id}/delete")
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

    # Delete user
    success = delete_user(db, user_id)
    if not success:
        raise HTTPException(status_code=404, detail="User not found or deletion failed")

    # Reset auto-increment to the max user_id + 1
    db.execute(text("ALTER TABLE `user` AUTO_INCREMENT = :next_id"), {"next_id": get_max_user_id(db) + 1})
    db.commit()

    # Notify admin
    create_notification(
        db,
        message=f"You have successfully deleted user {user.name}",
        type="info",
        user_id=current_user.user_id
    )

    return {
        "status": 200,
        "success": True,
        "message": f"User {user.name} deleted successfully"
    }


def get_max_user_id(db: Session) -> int:
    """Get the current maximum user_id from the user table"""
    result = db.execute(text("SELECT MAX(user_id) AS max_id FROM `user`"))
    max_id = result.fetchone()[0]
    return max_id or 0
