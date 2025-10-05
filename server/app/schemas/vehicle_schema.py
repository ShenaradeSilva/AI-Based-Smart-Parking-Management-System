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


class VehicleOut(VehicleBase):
    vehicle_id: int
    created_at: datetime
    is_primary: bool = False

    class Config:
        from_attributes = True
