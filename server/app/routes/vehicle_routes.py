from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List
from fastapi.responses import StreamingResponse
from io import StringIO
import csv

from ..schemas.vehicle_schema import VehicleCreate, VehicleUpdate, VehicleOut
from ..services import vehicle_services
from ..services.notification_services import create_notification
from ..database import get_db
from ..utils.auth_utils import decode_access_token
from fastapi.security import OAuth2PasswordBearer

router = APIRouter(prefix="/api/vehicles", tags=["Vehicles"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


@router.get("/list", response_model=List[VehicleOut])
def list_vehicles(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    user_payload = decode_access_token(token)
    return vehicle_services.get_all_vehicles(db)


@router.get("/{vehicle_id}/get", response_model=VehicleOut)
def get_vehicle(vehicle_id: int, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    user_payload = decode_access_token(token)
    return vehicle_services.get_vehicle_by_id(vehicle_id, db)


@router.post("/create", response_model=VehicleOut, status_code=status.HTTP_201_CREATED)
def create_vehicle(vehicle: VehicleCreate, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    user_payload = decode_access_token(token)
    new_vehicle = vehicle_services.create_vehicle(vehicle, db)

    # Notification
    create_notification(
        db,
        f"New vehicle {new_vehicle.plate_number} added",
        "info",
        user_id=user_payload["sub"]
    )

    return new_vehicle


@router.put("/{vehicle_id}/update", response_model=VehicleOut)
def update_vehicle(vehicle_id: int, data: VehicleUpdate, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    user_payload = decode_access_token(token)
    updated_vehicle = vehicle_services.update_vehicle(vehicle_id, data, db)

    # Notification
    create_notification(
        db,
        f"Vehicle {updated_vehicle.plate_number} details updated",
        "info",
        user_id=user_payload["sub"]
    )

    return updated_vehicle


@router.delete("/{vehicle_id}/delete", status_code=status.HTTP_204_NO_CONTENT)
def delete_vehicle(vehicle_id: int, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    user_payload = decode_access_token(token)
    vehicle = vehicle_services.get_vehicle_by_id(vehicle_id, db)
    if not vehicle:
        return {"detail": "Vehicle not found"}

    vehicle_services.delete_vehicle(vehicle_id, db)

    # Notification
    create_notification(
        db,
        f"Vehicle {vehicle.plate_number} was deleted",
        "cancellation",
        user_id=user_payload["sub"]
    )

    return {"detail": "Vehicle deleted successfully"}


# CSV Export Route
@router.get("/export-csv")
def export_vehicles_csv(db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    decode_access_token(token)
    vehicles = vehicle_services.get_vehicles_for_csv(db)

    output = StringIO()
    writer = csv.writer(output)
    writer.writerow(['Plate Number', 'Owner', 'Vehicle Type', 'Registered Date'])
    for v in vehicles:
        writer.writerow([v["plate_number"], v["owner"], v["type"], v["registered_date"]])

    output.seek(0)
    return StreamingResponse(
        output,
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=vehicles.csv"}
    )
