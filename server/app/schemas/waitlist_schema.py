from pydantic import BaseModel
from datetime import datetime
from typing import Optional


class WaitlistBase(BaseModel):
    user_id: int
    vehicle_id: int
    parking_slot_id: Optional[int] = None
    priority: Optional[str] = "Medium"


class WaitlistCreate(WaitlistBase):
    pass


class WaitlistUpdate(BaseModel):
    status: Optional[str] = None
    notified_at: Optional[datetime] = None
    parking_slot_id: Optional[int] = None


class WaitlistOut(BaseModel):
    waitlist_id: int
    user_id: int
    user_name: str
    vehicle_id: int
    vehicle_number: str
    parking_slot_id: Optional[int] = None
    parking_slot_number: Optional[str] = None
    requested_at: datetime
    status: str
    priority: str
    notified_at: Optional[datetime]

    class Config:
        orm_mode = True
