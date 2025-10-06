from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..services import waitlist_services
from ..services.notification_services import create_notification
from ..schemas.waitlist_schema import WaitlistCreate, WaitlistOut

router = APIRouter(prefix="/api/waitlist", tags=["Waitlist"])


@router.get("/get", response_model=List[WaitlistOut])
def get_waitlist_queue(db: Session = Depends(get_db)):
    waitlist = waitlist_services.get_waitlist(db)
    result = []
    for entry in waitlist:
        result.append(WaitlistOut(
            waitlist_id=entry.waitlist_id,
            user_id=entry.user_id,
            user_name=entry.user.name,
            vehicle_id=entry.vehicle_id,
            vehicle_number=entry.vehicle.plate_number,
            parking_slot_id=entry.parking_slot_id,
            parking_slot_number=entry.parking_slot.slot_number if entry.parking_slot else None,
            requested_at=entry.requested_at,
            status=entry.status,
            priority=entry.priority,
            notified_at=entry.notified_at
        ))
    return result


@router.post("/create", response_model=WaitlistOut)
def create_waitlist(waitlist: WaitlistCreate, db: Session = Depends(get_db)):
    entry = waitlist_services.create_waitlist(db, waitlist)
    if entry:
        # Notify user about waitlist addition
        create_notification(
            db,
            f"You have been added to the waitlist for slot {entry.parking_slot.slot_number if entry.parking_slot else 'N/A'}",
            "waitlist",
            user_id=entry.user_id
        )
    return entry


@router.post("/notify/{waitlist_id}", response_model=WaitlistOut)
def notify_driver(waitlist_id: int, db: Session = Depends(get_db)):
    entry = waitlist_services.notify_driver(db, waitlist_id)
    if not entry:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Waitlist entry not found")

    # Notification for being first in line
    create_notification(
        db,
        "You are now first on the waitlist",
        "waitlist",
        user_id=entry.user_id
    )

    return entry


@router.delete("/{waitlist_id}/remove", response_model=WaitlistOut)
def remove_waitlist(waitlist_id: int, db: Session = Depends(get_db)):
    entry = waitlist_services.remove_waitlist(db, waitlist_id)
    if not entry:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Waitlist entry not found")

    # Notification for removal
    create_notification(
        db,
        "Your waitlist entry has been removed",
        "cancellation",
        user_id=entry.user_id
    )

    return entry
