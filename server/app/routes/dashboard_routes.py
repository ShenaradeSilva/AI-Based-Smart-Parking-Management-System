from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..services import dashboard_services

router = APIRouter(prefix="/api/dashboard", tags=["Dashboard"])


@router.get("/")
def get_dashboard(db: Session = Depends(get_db)):
    """
    Get dashboard summary stats.

    Returns JSON with:
    - registeredVehicles
    - occupancyRate
    - totalUsers
    - notifications (total/unread)
    - uptimeStatus
    """
    return dashboard_services.get_dashboard_data(db)
