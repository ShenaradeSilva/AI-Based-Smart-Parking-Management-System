from sqlalchemy import Column, Integer, Enum, ForeignKey, Date, Time, DateTime, TIMESTAMP, func
from sqlalchemy.orm import relationship
from ..database import Base
import enum


class ReservationStatus(str, enum.Enum):
    pending = "pending"
    confirmed = "confirmed"
    active = "active"
    completed = "completed"
    cancelled = "cancelled"


class Reservation(Base):
    __tablename__ = "reservation"

    reservation_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    date = Column(Date, nullable=False)
    start_time = Column(Time, nullable=False)
    end_time = Column(Time, nullable=False)
    status = Column(Enum(ReservationStatus), default=ReservationStatus.pending, nullable=False)
    user_id = Column(Integer, ForeignKey("user.user_id", ondelete="CASCADE"), nullable=False)
    parking_slot_id = Column(Integer, ForeignKey("parkingslot.parking_slot_id", ondelete="CASCADE"), nullable=False)
    vehicle_id = Column(Integer, ForeignKey("vehicle.vehicle_id", ondelete="CASCADE"), nullable=False)

    actual_entry = Column(DateTime, nullable=True)
    actual_exit = Column(DateTime, nullable=True)

    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="reservations")
    parking_slot = relationship("ParkingSlot", back_populates="reservations")
    vehicle = relationship("Vehicle", back_populates="reservations")
    qr_codes = relationship("QRCode", back_populates="reservation", cascade="all, delete-orphan")
    cancellation_requests = relationship("CancellationRequest", back_populates="reservation", cascade="all, delete-orphan")
    waitlists = relationship("Waitlist", back_populates="reservation", cascade="all, delete-orphan")
