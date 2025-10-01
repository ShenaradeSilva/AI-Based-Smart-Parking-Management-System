from sqlalchemy import Column, Integer, Text, Enum, ForeignKey, TIMESTAMP, func
from sqlalchemy.orm import relationship
from ..database import Base
import enum


class NotificationType(str, enum.Enum):
    info = "info"
    security = "security"
    cancellation = "cancellation"
    waitlist = "waitlist"
    success = "success"


class NotificationStatus(str, enum.Enum):
    unread = "unread"
    read = "read"


class Notification(Base):
    __tablename__ = "notification"  # ← FIXED: Double underscores

    notification_id = Column(Integer, primary_key=True, index=True)
    message = Column(Text, nullable=False)
    type = Column(Enum(NotificationType), nullable=False)
    status = Column(Enum(NotificationStatus), default=NotificationStatus.unread)
    created_at = Column(TIMESTAMP, server_default=func.now(), nullable=False)
    user_id = Column(Integer, ForeignKey("user.user_id", ondelete="CASCADE"))

    user = relationship("User", back_populates="notifications")