from pydantic import BaseModel
from typing import Optional
from datetime import datetime


# Locations
class LocationBase(BaseModel):
    name: str
    address: str
    hourly_rate: Optional[float] = 150.0


class LocationCreate(LocationBase):
    total_slots: Optional[int] = 0  # Total slots at this location


class Location(LocationBase):
    location_id: int
    created_at: datetime
    created_by: Optional[int]  # Admin ID who added the location

    class Config:
        orm_mode = True


# Parking Slots
class ParkingSlotBase(BaseModel):
    slot_number: str
    slot_type: Optional[str] = "standard"
    status: Optional[str] = "available"


class ParkingSlotCreate(ParkingSlotBase):
    parking_lot_id: int


class ParkingSlot(ParkingSlotBase):
    parking_slot_id: int
    parking_lot_id: int
    created_by: Optional[int]  # Admin ID who added the slot
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        orm_mode = True


# Slot Operations Responses (optional)
class SlotOperationResponse(BaseModel):
    detail: str
