from sqlalchemy import Column, Integer, String, ForeignKey, TIMESTAMP, func
from sqlalchemy.orm import relationship
from ..database import Base


class Vehicle(Base):
    __tablename__ = "vehicle"

    vehicle_id = Column(Integer, primary_key=True, index=True)
    plate_number = Column(String(50), unique=True, nullable=False, index=True)
    type = Column(String(50), nullable=False)
    user_id = Column(Integer, ForeignKey("user.user_id", ondelete="CASCADE"), nullable=False)  # Added ondelete
    created_at = Column(TIMESTAMP, server_default=func.now())

    user = relationship("User", back_populates="vehicles")
    reservations = relationship("Reservation", back_populates="vehicle", cascade="all, delete-orphan")
    waitlists = relationship("Waitlist", back_populates="vehicle", cascade="all, delete-orphan")
    cancellation_requests = relationship("CancellationRequest", back_populates="vehicle", cascade="all, delete-orphan")