from sqlalchemy import Column, Integer, ForeignKey, Enum, TIMESTAMP, func
from sqlalchemy.orm import relationship
from ..database import Base
import enum


class WaitlistStatus(str, enum.Enum):
    pending = "pending"
    notified = "notified"
    cancelled = "cancelled"


class WaitlistPriority(str, enum.Enum):
    High = "High"
    Medium = "Medium"
    Low = "Low"


class Waitlist(Base):
    __tablename__ = "waitlist"

    waitlist_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("user.user_id", ondelete="CASCADE"), nullable=False)
    vehicle_id = Column(Integer, ForeignKey("vehicle.vehicle_id", ondelete="CASCADE"), nullable=False)
    parking_slot_id = Column(Integer, ForeignKey("parkingslot.parking_slot_id", ondelete="SET NULL"), nullable=True)
    reservation_id = Column(Integer, ForeignKey("reservation.reservation_id", ondelete="SET NULL"), nullable=True)
    requested_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    status = Column(Enum(WaitlistStatus), default=WaitlistStatus.pending, nullable=False)
    priority = Column(Enum(WaitlistPriority), default=WaitlistPriority.Medium, nullable=False)
    notified_at = Column(TIMESTAMP, nullable=True)

    # Relationships
    user = relationship("User", back_populates="waitlists")
    vehicle = relationship("Vehicle", back_populates="waitlists")
    parking_slot = relationship("ParkingSlot", back_populates="waitlists")
    reservation = relationship("Reservation", back_populates="waitlists")
