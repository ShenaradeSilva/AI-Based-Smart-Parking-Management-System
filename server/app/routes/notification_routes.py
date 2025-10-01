from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..schemas.notification_schema import NotificationResponse
from ..services import notification_services

router = APIRouter(prefix="/notifications", tags=["Notifications"])


# Dummy auth dependency (replace with real JWT auth)
def get_current_user():
    return {"user_id": 1, "role": "admin"}


@router.get("/", response_model=List[NotificationResponse])
def fetch_notifications(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    if current_user["role"] == "admin":
        return notification_services.get_all_notifications(db)
    return notification_services.get_user_notifications(db, current_user["user_id"])


@router.post("/{notification_id}/read", response_model=NotificationResponse)
def mark_as_read(notification_id: int, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    notif = notification_services.mark_notification_as_read(db, notification_id)
    if not notif:
        raise HTTPException(status_code=404, detail="Notification not found")
    return notif


# Optional: mark all notifications as read for current user
@router.post("/read-all", response_model=List[NotificationResponse])
def mark_all_as_read(db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    notifs = notification_services.get_user_notifications(db, current_user["user_id"], unread_only=True)
    updated = []
    for n in notifs:
        n.status = "read"
        db.commit()
        db.refresh(n)
        updated.append(n)
    return updated
