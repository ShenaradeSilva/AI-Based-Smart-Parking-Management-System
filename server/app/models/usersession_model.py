from sqlalchemy import Column, Integer, Text, DateTime, ForeignKey, TIMESTAMP, func
from sqlalchemy.orm import relationship
from ..database import Base


class UserSession(Base):
    __tablename__ = "usersession"

    session_id = Column(Integer, primary_key=True, autoincrement=True)
    token = Column(Text, nullable=False)
    expiry = Column(DateTime, nullable=False)  # DateTime in DB, not TIMESTAMP
    user_id = Column(Integer, ForeignKey("user.user_id", ondelete="CASCADE"), nullable=False)
    created_at = Column(TIMESTAMP, server_default=func.now())

    user = relationship("User", back_populates="sessions")