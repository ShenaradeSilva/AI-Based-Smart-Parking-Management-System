# src/routes/analytics_routes.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.analytics_services import (
    get_analytics_dashboard,
    get_vehicle_visit_frequency
)
from ..schemas.analytics_schema import (
    AnalyticsDashboardResponse,
    PeakTimeResponse
)
# from ai_model.model_predict import get_peak_time_predictions, vehicle_visit_frequency

router = APIRouter(prefix="/api/analytics", tags=["Analytics"])


@router.get("/dashboard", response_model=AnalyticsDashboardResponse)
def analytics_dashboard(db: Session = Depends(get_db)):
    """
    Returns combined analytics data including:
    - revenue stats (today, week, month, growth rate)
    - revenue trends (avg per slot/day, peak/off-peak)
    - performance metrics (utilization rate, avg stay duration)
    - reservation trends (last 7 days)
    - AI predictions (if active model exists)
    """
    return get_analytics_dashboard(db)


@router.get("/peak-times", response_model=PeakTimeResponse)
def get_peak_times():
    """
    Return historical and predicted peak times from AI model.
    """
    predictions = get_peak_time_predictions()
    return predictions


@router.get("/visit-frequency")
def vehicle_visit_frequency(db: Session = Depends(get_db)):
    """
    Returns frequency of vehicle visits per day, per vehicle_id.
    Useful for analyzing customer retention and usage patterns.
    """
    return get_vehicle_visit_frequency(db)
