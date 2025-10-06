from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class VehicleBase(BaseModel):
    plate_number: str
    type: str
    user_id: int


class VehicleCreate(VehicleBase):
    pass


class VehicleUpdate(BaseModel):
    plate_number: Optional[str] = None
    type: Optional[str] = None
    user_id: Optional[int] = None


class VehicleOut(BaseModel):
    vehicle_id: int
    plate_number: str
    type: str
    user_id: int
    owner: str  # <-- add this
    created_at: datetime
    is_primary: bool = False

    class Config:
        orm_mode = True
