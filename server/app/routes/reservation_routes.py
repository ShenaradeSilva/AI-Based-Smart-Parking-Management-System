from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..schemas.reservation_schema import ReservationCreate, ReservationResponse, ReservationUpdateStatus
from ..services import reservation_services
from ..services.notification_services import create_notification
from ..database import get_db

router = APIRouter(prefix="/api/reservations", tags=["Reservations"])


# GET all reservations (list)
@router.get("/", response_model=List[ReservationResponse])
def list_reservations(db: Session = Depends(get_db)):
    reservations = reservation_services.get_all_reservations(db)
    response = []
    for r in reservations:
        r_dict = ReservationResponse.from_orm(r).dict()
        r_dict["amount"] = reservation_services.calculate_amount(db, r.parking_slot_id, r.start_time, r.end_time)
        response.append(r_dict)
    return response


# GET reservation by ID (details)
@router.get("/{reservation_id}", response_model=ReservationResponse)
def get_reservation(reservation_id: int, db: Session = Depends(get_db)):
    reservation = reservation_services.get_reservation(db, reservation_id)
    if not reservation:
        raise HTTPException(status_code=404, detail="Reservation not found")
    r_dict = ReservationResponse.from_orm(reservation).dict()
    r_dict["amount"] = reservation_services.calculate_amount(db, reservation.parking_slot_id, reservation.start_time, reservation.end_time)
    return r_dict


# POST create reservation
@router.post("/", response_model=ReservationResponse, status_code=status.HTTP_201_CREATED)
def create_reservation(reservation: ReservationCreate, db: Session = Depends(get_db)):
    r = reservation_services.create_reservation(db, reservation)
    r_dict = ReservationResponse.from_orm(r).dict()
    r_dict["amount"] = reservation_services.calculate_amount(db, r.parking_slot_id, r.start_time, r.end_time)

    # Notification
    create_notification(
        db,
        f"Reservation created for slot {r.parking_slot_id} from {r.start_time} to {r.end_time}",
        "info",
        user_id=r.user_id
    )

    return r_dict


# PUT update status (e.g., cancel)
@router.put("/{reservation_id}/status", response_model=ReservationResponse)
def update_reservation_status(reservation_id: int, status: ReservationUpdateStatus, db: Session = Depends(get_db)):
    reservation = reservation_services.update_reservation_status(db, reservation_id, status)
    if not reservation:
        raise HTTPException(status_code=404, detail="Reservation not found")
    r_dict = ReservationResponse.from_orm(reservation).dict()
    r_dict["amount"] = reservation_services.calculate_amount(db, reservation.parking_slot_id, reservation.start_time, reservation.end_time)

    # Notification
    create_notification(
        db,
        f"Reservation status updated to '{status.status}' for slot {reservation.parking_slot_id}",
        "info",
        user_id=reservation.user_id
    )

    return r_dict


# DELETE reservation (cancel)
@router.delete("/{reservation_id}", response_model=ReservationResponse)
def cancel_reservation(reservation_id: int, db: Session = Depends(get_db)):
    reservation = reservation_services.delete_reservation(db, reservation_id)
    if not reservation:
        raise HTTPException(status_code=404, detail="Reservation not found")
    r_dict = ReservationResponse.from_orm(reservation).dict()
    r_dict["amount"] = reservation_services.calculate_amount(db, reservation.parking_slot_id, reservation.start_time, reservation.end_time)

    # Notification
    create_notification(
        db,
        f"Reservation canceled for slot {reservation.parking_slot_id}",
        "cancellation",
        user_id=reservation.user_id
    )

    return r_dict


# GET receipt of reservation
@router.get("/{reservation_id}/receipt")
def reservation_receipt(reservation_id: int, db: Session = Depends(get_db)):
    reservation = reservation_services.get_reservation(db, reservation_id)
    if not reservation:
        raise HTTPException(status_code=404, detail="Reservation not found")
    return reservation_services.print_reservation_receipt(db, reservation)
