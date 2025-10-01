from sqlalchemy import Column, Integer, Text, DateTime, Boolean, ForeignKey, TIMESTAMP, func
from sqlalchemy.orm import relationship
from ..database import Base


class QRCode(Base):
    __tablename__ = "qrcode"

    qr_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    code_data = Column(Text, nullable=False)
    generated_at = Column(TIMESTAMP, server_default=func.now())
    expires_at = Column(DateTime, nullable=False)  # DateTime in DB
    is_scanned = Column(Boolean, default=False)
    scanned_at = Column(DateTime, nullable=True)  # DateTime in DB
    reservation_id = Column(Integer, ForeignKey("reservation.reservation_id", ondelete="CASCADE"), nullable=False)

    reservation = relationship("Reservation", back_populates="qr_codes")
