# routes/auth_routes.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordBearer

from ..schemas.user_schema import (
    UserCreate, UserOut, SignInRequest, TokenResponse,
    PasswordResetRequest, PasswordResetVerify, PasswordResetConfirm
)
from ..services.auth_services import (
    create_admin, login_admin,
    send_reset_code, verify_reset_code, reset_password
)
from ..services.notification_services import create_notification
from ..database import get_db
from ..models.user_model import User

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/signin")


@router.post("/signup", response_model=UserOut)
def signup(user: UserCreate, db: Session = Depends(get_db)):
    try:
        new_admin = create_admin(db, user)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    if not new_admin:
        raise HTTPException(status_code=400, detail="Admin account with this email already exists.")

    # Notification: Signup success
    create_notification(db, "Signup successful", "success", user_id=new_admin.user_id)

    return new_admin


@router.post("/signin", response_model=TokenResponse)
def signin(payload: SignInRequest, db: Session = Depends(get_db)):
    result = login_admin(db, payload.email, payload.password)
    if not result:
        # Optional: Notification for failed login attempt (security alert)
        user = db.query(User).filter(User.email == payload.email).first()
        if user:
            create_notification(db, "Failed login attempt detected", "security", user_id=user.user_id)
        raise HTTPException(status_code=401, detail="Invalid credentials or not authorized")

    token, user = result

    # Notification: Signin success
    user = db.query(User).filter(User.email == payload.email).first()
    create_notification(db, "Login successful", "success", user_id=user.user_id)

    return {"access_token": token, "token_type": "bearer", "user": user}


# Reset Password - Step 1: Request code
@router.post("/reset-password/request")
def request_reset_password(request: PasswordResetRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    send_reset_code(user)  # <-- generates 4-digit code & sends email

    # Notification: Security alert for password reset request
    create_notification(db, "Password reset requested", "security", user_id=user.user_id)

    return {"message": "Verification code sent to email"}


# Reset Password - Step 2: Verify code
@router.post("/reset-password/verify")
def verify_reset_password(request: PasswordResetVerify, db: Session = Depends(get_db)):
    is_valid, msg = verify_reset_code(request.email, request.code)
    if not is_valid:
        raise HTTPException(status_code=400, detail=msg)

    # Optional: Could create notification for code verification success
    user = db.query(User).filter(User.email == request.email).first()
    create_notification(db, "Password reset code verified", "success", user_id=user.user_id)

    return {"message": "Code verified successfully"}


# Reset Password - Step 3: Confirm new password
@router.post("/reset-password/confirm")
def confirm_reset_password(request: PasswordResetConfirm, db: Session = Depends(get_db)):
    is_valid, msg = verify_reset_code(request.email, request.code)
    if not is_valid:
        raise HTTPException(status_code=400, detail=msg)

    user = db.query(User).filter(User.email == request.email).first()
    reset_password(user, request.new_password)
    db.commit()

    # Notification: Password successfully reset
    create_notification(db, "Password reset successfully", "success", user_id=user.user_id)

    return {"message": "Password reset successfully"}
