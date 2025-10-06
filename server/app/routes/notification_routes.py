from fastapi import APIRouter, Depends, HTTPException, Header, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..schemas.notification_schema import NotificationResponse
from ..services import notification_services
from ..utils.auth_utils import decode_access_token

router = APIRouter(prefix="/api/notifications", tags=["Notifications"])


def get_current_user(authorization: str = Header(...)):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token format")

    token = authorization.split(" ")[1]
    payload = decode_access_token(token)

    if payload is None:
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    user_id = payload.get("user_id") or payload.get("sub")
    role = payload.get("role")

    if not user_id or not role:
        raise HTTPException(status_code=401, detail="Token missing user_id or role")

    return {"user_id": int(user_id), "role": role}


@router.get("/fetch", response_model=List[NotificationResponse])
def fetch_notifications(
        db: Session = Depends(get_db),
        current_user: dict = Depends(get_current_user)
):
    user_id = current_user["user_id"]

    # Both admin and driver users ONLY see their own notifications
    return notification_services.get_user_notifications(db, user_id)


@router.post("/{notification_id}/read", response_model=NotificationResponse)
def mark_as_read(
        notification_id: int,
        db: Session = Depends(get_db),
        current_user: dict = Depends(get_current_user)
):
    notif = notification_services.get_notification_by_id(db, notification_id)
    if not notif:
        raise HTTPException(status_code=404, detail="Notification not found")

    # Users can only mark their own notifications as read
    if notif.user_id != current_user["user_id"]:
        raise HTTPException(status_code=403, detail="Cannot mark others' notifications as read")

    # Update status and commit to database
    notif.status = "read"
    db.commit()
    db.refresh(notif)
    return notif


@router.post("/read-all", response_model=List[NotificationResponse])
def mark_all_as_read(
        db: Session = Depends(get_db),
        current_user: dict = Depends(get_current_user)
):
    user_id = current_user["user_id"]

    # Users can only mark their own notifications as read
    notifications_to_update = notification_services.get_user_notifications(db, user_id, unread_only=True)

    updated = []
    for notif in notifications_to_update:
        # Update each notification status
        notif.status = "read"
        updated.append(notif)

    # Commit all changes to database
    db.commit()

    # Refresh each notification to get updated data
    for notif in updated:
        db.refresh(notif)

    return updated
