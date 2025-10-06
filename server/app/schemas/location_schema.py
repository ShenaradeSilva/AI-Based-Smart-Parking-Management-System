from pydantic import BaseModel
from datetime import datetime

# Admin creates a location
class LocationCreate(BaseModel):
    name: str
    address: str
    hourly_rate: float

# Response schema for all users
class LocationResponse(BaseModel):
    location_id: int
    name: str
    address: str
    hourly_rate: float
    lat: float | None = None
    lng: float | None = None
    created_at: datetime
    created_by: int | None = None

    class Config:
        orm_mode = True
