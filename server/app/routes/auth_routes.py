# routes/auth_routes.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordBearer

from ..schemas.user_schema import (
    DriverSignUp, AdminSignUp, UserOut, SignInRequest, TokenResponse, TokenWithUser,
    PasswordResetRequest, PasswordResetVerify, PasswordResetConfirm
)
from ..services.auth_services import (
    create_driver, create_admin, login_user,
    send_reset_code, verify_reset_code, reset_password
)
from ..services.notification_services import create_notification
from ..database import get_db
from ..models.user_model import User

router = APIRouter(prefix="/api/auth", tags=["Auth"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="signin")


@router.post("/driver/signup", response_model=UserOut)
def driver_signup(driver: DriverSignUp, db: Session = Depends(get_db)):
    """
    Signup endpoint for drivers. Creates driver + vehicle.
    """
    try:
        new_driver = create_driver(db, driver)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    if not new_driver:
        raise HTTPException(status_code=400, detail="Driver with this email already exists.")

    # Notification
    create_notification(db, "Driver signup successful", "success", user_id=new_driver.user_id)

    return new_driver


@router.post("/admin/signup", response_model=UserOut)
def signup(user: AdminSignUp, db: Session = Depends(get_db)):
    try:
        new_admin = create_admin(db, user)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    if not new_admin:
        raise HTTPException(status_code=400, detail="Admin account with this email already exists.")

    # Notification: Signup success
    create_notification(db, "Signup successful", "success", user_id=new_admin.user_id)

    return new_admin


@router.post("/signin", response_model=TokenWithUser)
def signin(payload: SignInRequest, db: Session = Depends(get_db)):
    # 1. Fetch user
    user = db.query(User).filter(User.email == payload.email).first()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    # 2. Check platform restrictions
    if user.role == "driver" and payload.platform != "mobile":
        raise HTTPException(status_code=403, detail="Drivers can only sign in from the mobile app")

    if user.role == "admin" and payload.platform != "web":
        raise HTTPException(status_code=403, detail="Admins can only sign in from the web app")

    # 3. Validate credentials
    token_user = login_user(db, payload.email, payload.password, payload.platform)
    if not token_user:
        create_notification(db, "Failed login attempt detected", "security", user_id=user.user_id)
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token, user = token_user

    # 4. Success notification
    create_notification(db, "Login successful", "success", user_id=user.user_id)

    return {"access_token": token, "token_type": "bearer", "user": user}


# Reset Password - Step 1: Request code
@router.post("/reset-password/request", response_model=dict)
def request_reset_password(request: PasswordResetRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    send_reset_code(user)
    create_notification(db, "Password reset requested", "security", user_id=user.user_id)
    return {"message": "Verification code sent to email"}


# Reset Password - Step 2: Verify code
@router.post("/reset-password/verify", response_model=dict)
def verify_reset_password(request: PasswordResetVerify, db: Session = Depends(get_db)):
    is_valid, msg = verify_reset_code(request.email, request.code)
    if not is_valid:
        raise HTTPException(status_code=400, detail=msg)

    user = db.query(User).filter(User.email == request.email).first()
    create_notification(db, "Password reset code verified", "success", user_id=user.user_id)
    return {"message": "Code verified successfully"}


# Reset Password - Step 3: Confirm new password
@router.post("/reset-password/confirm", response_model=dict)
def confirm_reset_password(request: PasswordResetConfirm, db: Session = Depends(get_db)):
    # Verify the code first
    is_valid, msg = verify_reset_code(request.email, request.code)
    if not is_valid:
        raise HTTPException(status_code=400, detail=msg)

    # Fetch the user
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Reset password using the correct function signature
    reset_password(db, user, request.new_password)

    # Log notification
    create_notification(db, "Password reset successfully", "success", user_id=user.user_id)

    return {"message": "Password reset successfully"}
