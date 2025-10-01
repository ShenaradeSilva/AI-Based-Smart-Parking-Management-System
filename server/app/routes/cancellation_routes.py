from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.cancellation_services import (
    get_cancellation_stats,
    get_pending_requests,
    approve_request,
    reject_request
)
from ..schemas.cancellation_schema import CancellationRequestOut
from ..services.notification_services import create_notification

router = APIRouter(prefix="/api/cancellations", tags=["Cancellations"])


@router.get("/stats")
def get_cancellation_stats_route(db: Session = Depends(get_db)):
    return get_cancellation_stats(db)


@router.get("/", response_model=list[CancellationRequestOut])
def list_pending_cancellations(db: Session = Depends(get_db)):
    requests = get_pending_requests(db)

    # Optional: notify admin(s) about pending requests
    for r in requests:
        create_notification(
            db,
            f"Pending cancellation request for reservation {r.reservation_id}.",
            "cancellation",
            user_id=r.reservation.created_by if hasattr(r.reservation, "created_by") else 1  # default admin ID
        )

    return [
        CancellationRequestOut(
            id=r.id,
            reservation_id=r.reservation_id,
            user_id=r.user_id,
            vehicle_id=r.vehicle_id,
            reason=r.reason,
            status=r.status,
            requested_at=r.requested_at,
            processed_at=r.processed_at,
            driver_name=r.user.name,
            vehicle_number=r.vehicle.plate_number,
            slot=r.reservation.parking_slot.slot_number
        )
        for r in requests
    ]


@router.post("/{request_id}/approve", response_model=CancellationRequestOut)
def approve_cancellation(request_id: int, db: Session = Depends(get_db)):
    request = approve_request(db, request_id)
    if not request:
        raise HTTPException(status_code=404, detail="Request not found")

    # Notify user about approval
    create_notification(
        db,
        f"Cancellation request for reservation {request.reservation_id} has been approved.",
        "cancellation",
        user_id=request.user_id
    )
    return request


@router.post("/{request_id}/reject", response_model=CancellationRequestOut)
def reject_cancellation(request_id: int, db: Session = Depends(get_db)):
    request = reject_request(db, request_id)
    if not request:
        raise HTTPException(status_code=404, detail="Request not found")

    # Notify user about rejection
    create_notification(
        db,
        f"Cancellation request for reservation {request.reservation_id} has been rejected.",
        "cancellation",
        user_id=request.user_id
    )
    return request
