from sqlalchemy import Column, Integer, String, Enum, ForeignKey, TIMESTAMP, func
from sqlalchemy.orm import relationship
from ..database import Base


class ParkingSlot(Base):
    __tablename__ = "parkingslot"

    parking_slot_id = Column(Integer, primary_key=True, index=True)
    slot_number = Column(String(50), nullable=False)
    slot_type = Column(String(50), nullable=False)
    status = Column(Enum("available", "occupied", "maintenance", "reserved"), default="available")
    parking_lot_id = Column(Integer, ForeignKey("parkinglot.parking_lot_id", ondelete="CASCADE"), nullable=False)
    created_by = Column(Integer, ForeignKey("user.user_id", ondelete="SET NULL"), nullable=True)  # Added back
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())

    parking_lot = relationship("ParkingLot", back_populates="parking_slots")
    reservations = relationship("Reservation", back_populates="parking_slot", cascade="all, delete-orphan")
    waitlists = relationship("Waitlist", back_populates="parking_slot", cascade="all, delete-orphan")
    creator = relationship("User")  # Relationship to the admin who created this slot