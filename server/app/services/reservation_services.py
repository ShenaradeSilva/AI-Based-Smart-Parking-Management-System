from sqlalchemy.orm import Session
from ..models.reservation_model import Reservation, ReservationStatus
from ..models.parkingslot_model import ParkingSlot
from ..schemas.reservation_schema import ReservationCreate, ReservationUpdateStatus
from datetime import datetime, date, time


# --- Helper function to calculate amount ---
def calculate_amount(db: Session, parking_slot_id: int, start_time: time, end_time: time) -> float:
    slot = db.query(ParkingSlot).filter(ParkingSlot.parking_slot_id == parking_slot_id).first()
    if not slot:
        return 0.0
    # hourly_rate comes from location through parking lot
    hourly_rate = getattr(slot.parkinglot.location, "hourly_rate", 0)
    # duration in hours
    duration = (datetime.combine(date.today(), end_time) - datetime.combine(date.today(), start_time)).seconds / 3600
    return round(duration * hourly_rate, 2)


def get_all_reservations(db: Session):
    return db.query(Reservation).order_by(Reservation.date.desc(), Reservation.start_time.asc()).all()


def get_reservation(db: Session, reservation_id: int):
    return db.query(Reservation).filter(Reservation.reservation_id == reservation_id).first()


def create_reservation(db: Session, reservation: ReservationCreate):
    db_reservation = Reservation(
        date=reservation.date,
        start_time=reservation.start_time,
        end_time=reservation.end_time,
        status=reservation.status,
        user_id=reservation.user_id,
        parking_slot_id=reservation.parking_slot_id,
        vehicle_id=reservation.vehicle_id,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    db.add(db_reservation)
    db.commit()
    db.refresh(db_reservation)
    return db_reservation


def update_reservation_status(db: Session, reservation_id: int, status: ReservationUpdateStatus):
    reservation = db.query(Reservation).filter(Reservation.reservation_id == reservation_id).first()
    if reservation:
        reservation.status = status.status
        db.commit()
        db.refresh(reservation)
    return reservation


def delete_reservation(db: Session, reservation_id: int):
    reservation = db.query(Reservation).filter(Reservation.reservation_id == reservation_id).first()
    if reservation:
        db.delete(reservation)
        db.commit()
    return reservation


def print_reservation_receipt(db: Session, reservation: Reservation):
    amount = calculate_amount(db, reservation.parking_slot_id, reservation.start_time, reservation.end_time)
    return {
        "Reservation ID": reservation.reservation_id,
        "User ID": reservation.user_id,
        "Vehicle ID": reservation.vehicle_id,
        "Parking Slot": reservation.parking_slot_id,
        "Date": reservation.date,
        "Start Time": reservation.start_time,
        "End Time": reservation.end_time,
        "Status": reservation.status.value,
        "Amount": amount,
        "Created At": reservation.created_at,
        "Updated At": reservation.updated_at
    }
