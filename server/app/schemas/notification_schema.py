from pydantic import BaseModel, Field
from datetime import datetime


class NotificationResponse(BaseModel):
    id: int = Field(..., alias="notification_id")
    message: str
    type: str
    status: str
    created_at: datetime
    user_id: int

    class Config:
        orm_mode = True
        allow_population_by_field_name = True