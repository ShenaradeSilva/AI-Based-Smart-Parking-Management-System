from sqlalchemy.orm import Session
from ..models.parkinglot_model import ParkingLot
from ..models.parkingslot_model import ParkingSlot
import csv
from io import StringIO


# Parking Lots
def get_parkinglots(db: Session, location_id: int = None):
    query = db.query(ParkingLot)
    if location_id:
        query = query.filter(ParkingLot.location_id == location_id)
    return query.all()


# Parking Slots
def get_parking_slots(db: Session, parking_lot_id: int = None):
    query = db.query(ParkingSlot)
    if parking_lot_id:
        query = query.filter(ParkingSlot.parking_lot_id == parking_lot_id)
    return query.all()


def create_parking_slot(db: Session, slot_number: str, parking_lot_id: int, created_by: int = None, slot_type: str = "standard"):
    slot = ParkingSlot(
        slot_number=slot_number,
        parking_lot_id=parking_lot_id,
        slot_type=slot_type,
        created_by=created_by
    )
    db.add(slot)
    db.commit()
    db.refresh(slot)
    return slot


def update_slot_status(db: Session, slot_id: int, new_status: str):
    slot = db.query(ParkingSlot).filter(ParkingSlot.parking_slot_id == slot_id).first()
    if slot:
        slot.status = new_status
        db.commit()
        db.refresh(slot)
    return slot


def delete_parking_slot(db: Session, slot_id: int):
    slot = db.query(ParkingSlot).filter(ParkingSlot.parking_slot_id == slot_id).first()
    if slot:
        creator_id = slot.created_by
        db.delete(slot)
        db.commit()
        return True, creator_id
    return False, None


# Slot Operations
def export_slots(db: Session):
    slots = db.query(ParkingSlot).all()
    output = StringIO()
    writer = csv.writer(output)
    writer.writerow(["Slot ID", "Slot Number", "Type", "Status", "Parking Lot ID", "Created By", "Created At", "Updated At"])
    for s in slots:
        writer.writerow([s.parking_slot_id, s.slot_number, s.slot_type, s.status, s.parking_lot_id, s.created_by, s.created_at, s.updated_at])
    output.seek(0)
    return output


def mark_slot_maintenance(db: Session, slot_id: int):
    return update_slot_status(db, slot_id, "maintenance")


def optimize_slot_allocation(db: Session):
    lots = db.query(ParkingLot).all()
    for lot in lots:
        available_count = db.query(ParkingSlot).filter(
            ParkingSlot.parking_lot_id == lot.parking_lot_id,
            ParkingSlot.status == "available"
        ).count()
        lot.available_slots = available_count
    db.commit()
