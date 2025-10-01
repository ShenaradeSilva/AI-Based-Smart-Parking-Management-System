from sqlalchemy import Column, Integer, String, Enum, Text, TIMESTAMP, CHAR, func
from sqlalchemy.orm import relationship
from ..database import Base
import enum


class UserRole(str, enum.Enum):
    admin = "admin"
    driver = "driver"


class UserStatus(str, enum.Enum):
    active = "active"
    inactive = "inactive"


class User(Base):
    __tablename__ = "user"

    user_id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(CHAR(60), nullable=False)
    phone = Column(String(50), nullable=True)
    profile_picture = Column(Text, nullable=True)
    role = Column(Enum(UserRole), nullable=False, default=UserRole.admin, server_default=UserRole.admin.value)
    status = Column(String, default="active")
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())

    # Relationships with cascade delete
    sessions = relationship("UserSession", back_populates="user", cascade="all, delete-orphan")
    vehicles = relationship("Vehicle", back_populates="user", cascade="all, delete-orphan")
    reservations = relationship("Reservation", back_populates="user", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")
    waitlists = relationship("Waitlist", back_populates="user", cascade="all, delete-orphan")
    cancellation_requests = relationship("CancellationRequest", back_populates="user", cascade="all, delete-orphan")
