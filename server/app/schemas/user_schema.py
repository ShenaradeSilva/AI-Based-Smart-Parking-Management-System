from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from enum import Enum
from datetime import datetime
from ..models.user_model import UserRole


class UserStatus(str, Enum):
    active = "active"
    inactive = "inactive"


# User creation (admin or self)
class UserCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    email: EmailStr
    password: Optional[str] = Field(None, min_length=6, max_length=100)  # optional if generated
    phone: Optional[str] = Field(None, max_length=50)
    role: UserRole = UserRole.driver
    status: UserStatus = UserStatus.active
    send_credentials: Optional[bool] = True

    class Config:
        from_attributes = True


# Admin update (role & status only)
class UserAdminUpdate(BaseModel):
    role: Optional[UserRole] = None
    status: Optional[UserStatus] = None

    class Config:
        from_attributes = True


# Sign in
class SignInRequest(BaseModel):
    email: EmailStr
    password: str

    class Config:
        from_attributes = True


# User output (generic)
class UserOut(BaseModel):
    user_id: int
    name: str
    email: EmailStr
    phone: Optional[str]
    role: UserRole
    status: UserStatus

    class Config:
        from_attributes = True


# Token response
class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"

    class Config:
        from_attributes = True


# Password reset flows
class PasswordResetRequest(BaseModel):
    email: EmailStr


class PasswordResetVerify(BaseModel):
    email: EmailStr
    code: str


class PasswordResetConfirm(BaseModel):
    email: EmailStr
    code: str
    new_password: str


# User profile update (self)
class UserProfileUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    phone: Optional[str] = Field(None, max_length=50)
    password: Optional[str] = Field(None, min_length=6, max_length=100)
    remove_picture: Optional[bool] = False
    profile_picture: Optional[str] = None

    class Config:
        from_attributes = True


# ✅ Moved OUTSIDE, top-level class
class UserProfileOut(BaseModel):
    user_id: int
    name: str
    email: EmailStr
    phone: Optional[str]
    role: UserRole
    status: str
    profilePicture: Optional[str] = Field(None, alias="profile_picture")
    join_date: Optional[datetime] = Field(None, alias="created_at")

    class Config:
        orm_mode = True
        allow_population_by_field_name = True
