from pydantic import BaseModel
from typing import Optional
from datetime import datetime


# Parking Slots
class ParkingSlotBase(BaseModel):
    slot_number: str
    slot_type: Optional[str] = "vehicle"
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
