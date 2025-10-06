from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from enum import Enum
from datetime import datetime
from ..models.user_model import UserRole
from ..schemas.vehicle_schema import VehicleOut


# ------------------------------
# ENUMS
# ------------------------------
class UserStatus(str, Enum):
    active = "active"
    inactive = "inactive"


# ------------------------------
# DRIVER SIGNUP
# ------------------------------
class DriverSignUp(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    email: EmailStr
    password: str = Field(..., min_length=6, max_length=100)
    phone: Optional[str] = Field(None, max_length=50)

    # Vehicle info
    vehicle_number: str = Field(..., max_length=50)
    vehicle_type: str = Field(..., max_length=50)

    class Config:
        from_attributes = True


# ------------------------------
# ADMIN SIGNUP
# ------------------------------
class AdminSignUp(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    email: EmailStr
    password: Optional[str] = Field(None, min_length=6, max_length=100)  # optional if generated
    phone: Optional[str] = Field(None, max_length=50)
    role: UserRole = UserRole.admin
    status: UserStatus = UserStatus.active
    send_credentials: Optional[bool] = True

    class Config:
        from_attributes = True


# ------------------------------
# USER CREATE (GENERIC)
# ------------------------------
class UserCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    email: EmailStr
    password: Optional[str] = Field(None, min_length=6, max_length=100)
    phone: Optional[str] = Field(None, max_length=50)
    role: UserRole = UserRole.driver  # can be overridden
    status: UserStatus = UserStatus.active
    send_credentials: Optional[bool] = True

    class Config:
        from_attributes = True


# ------------------------------
# USER PROFILE OUTPUT
# ------------------------------
class UserProfileOut(BaseModel):
    user_id: int
    name: str
    email: EmailStr
    phone: Optional[str]
    role: UserRole
    status: str
    profile_picture: Optional[str] = None
    join_date: Optional[datetime] = None
    vehicles: List[VehicleOut] = []

    class Config:
        from_attributes = True


# ------------------------------
# USER CREATE RESPONSE
# ------------------------------
class UserCreateResponse(BaseModel):
    status: int
    success: bool
    message: str
    data: UserProfileOut


# ------------------------------
# ADMIN UPDATE
# ------------------------------
class UserAdminUpdate(BaseModel):
    role: Optional[UserRole] = None
    status: Optional[UserStatus] = None

    class Config:
        from_attributes = True


# ------------------------------
# SIGN IN
# ------------------------------
class SignInRequest(BaseModel):
    email: EmailStr
    password: str
    platform: str = Field(..., description="Platform: 'web' for admin, 'mobile' for driver")

    class Config:
        from_attributes = True


# ------------------------------
# USER OUTPUT
# ------------------------------
class UserOut(BaseModel):
    user_id: int
    name: str
    email: EmailStr
    phone: Optional[str]
    role: UserRole
    status: UserStatus

    class Config:
        from_attributes = True


# ------------------------------
# TOKEN RESPONSES
# ------------------------------
class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

    class Config:
        from_attributes = True


class TokenWithUser(TokenResponse):
    user: UserOut


# ------------------------------
# PASSWORD RESET FLOWS
# ------------------------------
class PasswordResetRequest(BaseModel):
    email: EmailStr


class PasswordResetVerify(BaseModel):
    email: EmailStr
    code: str


class PasswordResetConfirm(BaseModel):
    email: EmailStr
    code: str
    new_password: str


# ------------------------------
# USER PROFILE UPDATE (SELF)
# ------------------------------
class UserProfileUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    phone: Optional[str] = Field(None, max_length=50)
    password: Optional[str] = Field(None, min_length=6, max_length=100)
    remove_picture: Optional[bool] = False
    profile_picture: Optional[str] = None

    class Config:
        from_attributes = True
