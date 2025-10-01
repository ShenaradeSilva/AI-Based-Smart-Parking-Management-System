from pydantic import BaseModel, validator
from datetime import date, time, datetime
from typing import Optional
from ..models.reservation_model import ReservationStatus


class ReservationBase(BaseModel):
    date: date
    start_time: time
    end_time: time
    status: Optional[ReservationStatus] = ReservationStatus.pending
    user_id: int
    parking_slot_id: int
    vehicle_id: Optional[int] = None


class ReservationCreate(ReservationBase):
    @validator("end_time")
    def end_time_after_start_time(cls, v, values):
        start = values.get("start_time")
        if start and v <= start:
            raise ValueError("end_time must be after start_time")
        return v

    @validator("date")
    def date_not_in_past(cls, v):
        if v < date.today():
            raise ValueError("date cannot be in the past")
        return v


class ReservationUpdateStatus(BaseModel):
    status: ReservationStatus


class ReservationResponse(ReservationBase):
    reservation_id: int
    created_at: datetime
    updated_at: datetime
    amount: float  # new field

    class Config:
        orm_mode = True
