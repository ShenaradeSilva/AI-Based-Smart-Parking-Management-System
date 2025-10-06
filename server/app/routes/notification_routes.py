from fastapi import APIRouter, Depends, HTTPException, Header, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..schemas.notification_schema import NotificationResponse
from ..services import notification_services
from ..utils.auth_utils import decode_access_token

router = APIRouter(prefix="/api/notifications", tags=["Notifications"])


# JWT-based user extractor with debug logging
def get_current_user(authorization: str = Header(...)):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token format")

    token = authorization.split(" ")[1]

    # Debug logs
    print("=== Incoming token ===")
    print(token)

    payload = decode_access_token(token)

    if payload is None:
        print("=== Token decode failed ===")
        raise HTTPException(status_code=401, detail="Invalid or expired token")

    print("=== Decoded payload ===")
    print(payload)

    # Fix: support both "user_id" and "sub"
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
    role = current_user["role"]

    if role == "admin":
        all_notifications = notification_services.get_all_notifications(db)
        filtered_notifications = []
        for notif in all_notifications:
            # Include signup/signin only if it belongs to this admin
            if notif.type in ["signup", "signin"]:
                if notif.user_id == user_id:
                    filtered_notifications.append(notif)
            else:
                # Include all other notifications for admin
                filtered_notifications.append(notif)
        return filtered_notifications
    else:
        # Driver sees only their own notifications
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

    if current_user["role"] != "admin" and notif.user_id != current_user["user_id"]:
        raise HTTPException(status_code=403, detail="Cannot mark others' notifications as read")

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
    role = current_user["role"]

    if role == "admin":
        notifications = notification_services.get_all_notifications(db)
    else:
        notifications = notification_services.get_user_notifications(db, user_id, unread_only=True)

    updated = []
    for notif in notifications:
        if role != "admin" and notif.user_id != user_id:
            continue
        notif.status = "read"
        updated.append(notif)

    # Commit once for efficiency
    db.commit()
    return updated
