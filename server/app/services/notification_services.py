from sqlalchemy.orm import Session
from ..models.notification_model import Notification, NotificationType, NotificationStatus
from typing import List
from datetime import datetime


def get_all_notifications(db: Session) -> List[Notification]:
    return db.query(Notification).order_by(Notification.created_at.desc()).all()


def get_user_notifications(db: Session, user_id: int, unread_only: bool = False) -> List[Notification]:
    query = db.query(Notification).filter(Notification.user_id == user_id)
    if unread_only:
        query = query.filter(Notification.status == NotificationStatus.unread)
    return query.order_by(Notification.created_at.desc()).all()


def mark_notification_as_read(db: Session, notification_id: int):
    notif = db.query(Notification).filter(Notification.notification_id == notification_id).first()
    if notif:
        notif.status = NotificationStatus.read
        db.commit()
        db.refresh(notif)
    return notif


def create_notification(db: Session, message: str, type: str, user_id: int):
    notif = Notification(
        message=message,
        type=NotificationType(type),
        status=NotificationStatus.unread,
        user_id=user_id

    )
    db.add(notif)
    db.commit()
    db.refresh(notif)
    return notif
