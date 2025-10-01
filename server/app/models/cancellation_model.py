from sqlalchemy import Column, Integer, String, ForeignKey, Enum, TIMESTAMP, func
from sqlalchemy.orm import relationship
from ..database import Base
import enum


class CancellationStatus(str, enum.Enum):
    pending = 'pending'
    approved = 'approved'
    rejected = 'rejected'


class CancellationRequest(Base):
    __tablename__ = "cancellationrequest"

    id = Column(Integer, primary_key=True, index=True)
    reservation_id = Column(Integer, ForeignKey("reservation.reservation_id", ondelete="CASCADE"), nullable=False)
    user_id = Column(Integer, ForeignKey("user.user_id", ondelete="CASCADE"), nullable=False)
    vehicle_id = Column(Integer, ForeignKey("vehicle.vehicle_id", ondelete="CASCADE"), nullable=False)
    reason = Column(String(255), nullable=True)
    status = Column(Enum(CancellationStatus), default=CancellationStatus.pending)
    requested_at = Column(TIMESTAMP, server_default=func.now())
    processed_at = Column(TIMESTAMP, nullable=True)

    user = relationship("User", back_populates="cancellation_requests")
    vehicle = relationship("Vehicle", back_populates="cancellation_requests")
    reservation = relationship("Reservation", back_populates="cancellation_requests")
