from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from ..models.vehicle_model import Vehicle
from ..schemas.vehicle_schema import VehicleCreate, VehicleUpdate


def get_all_vehicles(db: Session):
    return db.query(Vehicle).all()


def get_vehicle_by_id(vehicle_id: int, db: Session):
    vehicle = db.query(Vehicle).filter(Vehicle.vehicle_id == vehicle_id).first()
    if not vehicle:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Vehicle not found")
    return vehicle




def get_vehicle_by_plate(plate_number: str, db: Session):
    return db.query(Vehicle).filter(Vehicle.plate_number == plate_number).first()


def create_vehicle(vehicle: VehicleCreate, db: Session):
    if get_vehicle_by_plate(vehicle.plate_number, db):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Plate number already exists")
    new_vehicle = Vehicle(**vehicle.dict())
    db.add(new_vehicle)
    db.commit()
    db.refresh(new_vehicle)
    return new_vehicle


def update_vehicle(vehicle_id: int, data: VehicleUpdate, db: Session):
    vehicle = get_vehicle_by_id(vehicle_id, db)
    for field, value in data.dict(exclude_unset=True).items():
        setattr(vehicle, field, value)
    db.commit()
    db.refresh(vehicle)
    return vehicle


def delete_vehicle(vehicle_id: int, db: Session):
    vehicle = get_vehicle_by_id(vehicle_id, db)
    db.delete(vehicle)
    db.commit()


# Optional helper for CSV export
def get_vehicles_for_csv(db: Session):
    vehicles = get_all_vehicles(db)
    csv_list = []
    for v in vehicles:
        csv_list.append({
            "plate_number": v.plate_number,
            "owner": v.owner,
            "vehicle_type": v.type,
            "registered_date": v.registered_date
        })
    return csv_list
