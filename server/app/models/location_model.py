from sqlalchemy import Column, String, Integer, DECIMAL, Text, TIMESTAMP, String, ForeignKey, func
from sqlalchemy.orm import relationship
from ..database import Base


class Location(Base):
    __tablename__ = "location"

    location_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    address = Column(Text, nullable=False)
    hourly_rate = Column(DECIMAL(10, 2), nullable=False, default=150.0)
    created_at = Column(TIMESTAMP, server_default=func.now())
    created_by = Column(Integer, ForeignKey("user.user_id", ondelete="SET NULL"), nullable=True)  # Added back

    parking_lots = relationship("ParkingLot", back_populates="location", cascade="all, delete-orphan")
    creator = relationship("User")  # Relationship to the admin who created this location