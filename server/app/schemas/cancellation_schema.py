from pydantic import BaseModel
from datetime import datetime
from enum import Enum


class CancellationStatus(str, Enum):
    pending = 'pending'
    approved = 'approved'
    rejected = 'rejected'


class CancellationRequestBase(BaseModel):
    reservation_id: int
    user_id: int
    vehicle_id: int
    reason: str


class CancellationRequestOut(CancellationRequestBase):
    id: int
    status: CancellationStatus
    requested_at: datetime
    processed_at: datetime | None = None

    driver_name: str
    vehicle_number: str
    slot: str

    class Config:
        orm_mode = True
