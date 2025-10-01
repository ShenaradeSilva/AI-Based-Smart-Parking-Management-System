from sqlalchemy import Column, Integer, String, ForeignKey, TIMESTAMP, func
from sqlalchemy.orm import relationship
from ..database import Base


class ParkingLot(Base):
    __tablename__ = "parkinglot"  # Matches actual table name

    parking_lot_id = Column(Integer, primary_key=True, index=True)
    lot_name = Column(String(255), nullable=False)
    location_id = Column(Integer, ForeignKey("location.location_id", ondelete="CASCADE"), nullable=False)
    total_slots = Column(Integer, default=0, nullable=False)  # Added nullable=False
    available_slots = Column(Integer, default=0, nullable=False)  # Added nullable=False
    created_at = Column(TIMESTAMP, server_default=func.now())
    updated_at = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())

    location = relationship("Location", back_populates="parking_lots")
    parking_slots = relationship("ParkingSlot", back_populates="parking_lot", cascade="all, delete-orphan")