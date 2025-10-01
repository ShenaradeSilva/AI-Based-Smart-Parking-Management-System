from pydantic import BaseModel
from typing import Optional


class QRScanResult(BaseModel):
    vehicleNumber: str
    userName: str
    parkingSlotNumber: str
    date: str
    reservationPeriod: str
    paymentAmount: str
    rawData: Optional[str]

    class Config:
        orm_mode = True
