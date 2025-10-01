from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from fastapi.responses import StreamingResponse
from ..database import get_db
from ..schemas.parking_schema import Location, LocationCreate, ParkingSlot, ParkingSlotCreate
from ..services import parking_services
from ..services.notification_services import create_notification

router = APIRouter(prefix="/parking", tags=["Parking"])


# Locations
@router.get("/locations", response_model=List[Location])
def list_locations(db: Session = Depends(get_db)):
    return parking_services.get_locations(db)


@router.post("/locations", response_model=Location)
def add_location(location: LocationCreate, admin_id: int = Query(...), db: Session = Depends(get_db)):
    new_location = parking_services.create_location(
        db,
        name=location.name,
        address=location.address,
        hourly_rate=location.hourly_rate,
        created_by=admin_id
    )

    # Notification
    create_notification(
        db,
        f"New location added: {new_location.name}",
        "success",
        user_id=admin_id
    )
    return new_location


# Parking Slots
@router.get("/slots", response_model=List[ParkingSlot])
def list_slots(parking_lot_id: int = Query(None), db: Session = Depends(get_db)):
    return parking_services.get_parking_slots(db, parking_lot_id=parking_lot_id)


@router.post("/slots", response_model=ParkingSlot)
def add_slot(slot: ParkingSlotCreate, admin_id: int = Query(...), db: Session = Depends(get_db)):
    new_slot = parking_services.create_parking_slot(
        db,
        slot_number=slot.slot_number,
        parking_lot_id=slot.parking_lot_id,
        slot_type=slot.slot_type,
        created_by=admin_id
    )

    # Notification
    create_notification(
        db,
        f"New parking slot {new_slot.slot_number} added to lot {new_slot.parking_lot_id}",
        "success",
        user_id=admin_id
    )
    return new_slot


@router.put("/slots/{slot_id}/status", response_model=ParkingSlot)
def update_slot_status(slot_id: int, status: str = Query(...), db: Session = Depends(get_db)):
    updated = parking_services.update_slot_status(db, slot_id, status)
    if not updated:
        raise HTTPException(status_code=404, detail="Slot not found")

    # Notification
    create_notification(
        db,
        f"Slot {slot_id} status updated to {status}",
        "info",
        user_id=updated.created_by or 1
    )
    return updated


@router.put("/slots/{slot_id}/maintenance", response_model=ParkingSlot)
def mark_slot_maintenance(slot_id: int, db: Session = Depends(get_db)):
    updated = parking_services.mark_slot_maintenance(db, slot_id)
    if not updated:
        raise HTTPException(status_code=404, detail="Slot not found")

    # Notification
    create_notification(
        db,
        f"Slot {slot_id} marked for maintenance",
        "info",
        user_id=updated.created_by or 1
    )
    return updated


@router.delete("/slots/{slot_id}")
def delete_slot(slot_id: int, db: Session = Depends(get_db)):
    success, creator_id = parking_services.delete_parking_slot(db, slot_id)
    if not success:
        raise HTTPException(status_code=404, detail="Slot not found")

    # Notification
    create_notification(
        db,
        f"Slot {slot_id} has been deleted",
        "info",
        user_id=creator_id or 1
    )
    return {"detail": "Slot deleted successfully"}


@router.get("/slots/export")
def export_slots(db: Session = Depends(get_db)):
    output = parking_services.export_slots(db)

    # Optional notification
    create_notification(
        db,
        "Parking slots exported as CSV",
        "info",
        user_id=1
    )

    return StreamingResponse(
        output,
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=parking_slots.csv"}
    )


@router.put("/slots/optimize")
def optimize_slots(db: Session = Depends(get_db)):
    parking_services.optimize_slot_allocation(db)

    # Notification
    create_notification(
        db,
        "Parking slots optimized",
        "info",
        user_id=1
    )

    return {"detail": "Slot allocation optimized successfully"}
