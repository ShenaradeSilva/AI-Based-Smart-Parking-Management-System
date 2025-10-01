from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime
from ..models.cancellation_model import CancellationRequest, CancellationStatus
from ..models.notification_model import Notification


def get_cancellation_stats(db: Session):
    today = date.today()

    # Count today's requests
    today_requests = db.query(func.count(CancellationRequest.id))\
        .filter(func.date(CancellationRequest.requested_at) == today).scalar()

    # Calculate approval rate
    total_requests = db.query(func.count(CancellationRequest.id)).scalar()
    approved_requests = db.query(func.count(CancellationRequest.id))\
        .filter(CancellationRequest.status == CancellationStatus.approved).scalar()

    approval_rate = (approved_requests / total_requests * 100) if total_requests else 0

    return {
        "todayRequests": today_requests,
        "approvalRate": round(approval_rate, 2)
    }


def get_pending_requests(db: Session):
    return db.query(CancellationRequest).filter(CancellationRequest.status == CancellationStatus.pending).all()


def approve_request(db: Session, request_id: int):
    request = db.query(CancellationRequest).filter(CancellationRequest.id == request_id).first()
    if request:
        request.status = CancellationStatus.approved
        request.processed_at = datetime.utcnow()
        db.add(request)
        db.commit()
        db.refresh(request)

        notification = Notification(
            user_id=request.user_id,
            message=f"Your cancellation request for reservation {request.reservation_id} has been APPROVED.",
            type="cancellation"
        )
        db.add(notification)
        db.commit()
    return request


def reject_request(db: Session, request_id: int):
    request = db.query(CancellationRequest).filter(CancellationRequest.id == request_id).first()
    if request:
        request.status = CancellationStatus.rejected
        request.processed_at = datetime.utcnow()
        db.add(request)
        db.commit()
        db.refresh(request)

        notification = Notification(
            user_id=request.user_id,
            message=f"Your cancellation request for reservation {request.reservation_id} has been REJECTED.",
            type="cancellation"
        )
        db.add(notification)
        db.commit()
    return request
