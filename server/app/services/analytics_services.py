# src/services/analytics_services.py
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import date, timedelta
from collections import defaultdict
from ..models.reservation_model import Reservation
from ..models.parkingslot_model import ParkingSlot
from ..models.ai_model import AIModel
from ..schemas.analytics_schema import (
    RevenueStats,
    RevenueTrends,
    PerformanceMetrics,
    TrendItem,
    TrendResponse,
    AnalyticsDashboardResponse,
    PredictionResult
)
import joblib
import os


def load_active_model(db: Session):
    """
    Load the currently active AI model from DB if available.
    """
    model_record = db.query(AIModel).filter(AIModel.is_active == True).first()
    if not model_record:
        return None
    model_path = f"models/{model_record.model_name}_{model_record.version}.pkl"
    if os.path.exists(model_path):
        return joblib.load(model_path)
    return None


def get_analytics_dashboard(db: Session) -> AnalyticsDashboardResponse:
    """
    Compute full analytics dashboard:
    - Revenue stats
    - Revenue trends (avg/peak/off-peak)
    - Performance metrics (utilization, avg stay)
    - Reservation trends (last 7 days)
    - AI predictions (next 7 days)
    """
    today = date.today()

    # --- Revenue Calculations ---
    today_revenue = db.query(func.sum(Reservation.amount)).filter(
        Reservation.date == today,
        Reservation.status == "completed"
    ).scalar() or 0

    week_start = today - timedelta(days=today.weekday())
    week_revenue = db.query(func.sum(Reservation.amount)).filter(
        Reservation.date >= week_start,
        Reservation.status == "completed"
    ).scalar() or 0

    month_start = today.replace(day=1)
    month_revenue = db.query(func.sum(Reservation.amount)).filter(
        Reservation.date >= month_start,
        Reservation.status == "completed"
    ).scalar() or 0

    yesterday = today - timedelta(days=1)
    yesterday_revenue = db.query(func.sum(Reservation.amount)).filter(
        Reservation.date == yesterday,
        Reservation.status == "completed"
    ).scalar() or 1
    growth_rate = ((today_revenue / yesterday_revenue) - 1) * 100

    revenue_stats = RevenueStats(
        today=today_revenue,
        week=week_revenue,
        month=month_revenue,
        growth_rate=round(growth_rate, 1)
    )

    # --- Revenue Trends ---
    total_slots = db.query(func.count(ParkingSlot.parking_slot_id)).scalar() or 1
    avg_per_slot = today_revenue / total_slots

    peak_revenue = db.query(func.sum(Reservation.amount)).filter(
        Reservation.date == today,
        Reservation.hour >= 18,
        Reservation.hour <= 20,
        Reservation.status == "completed"
    ).scalar() or 0

    offpeak_revenue = today_revenue - peak_revenue

    revenue_trends = RevenueTrends(
        avg_per_slot_day=round(avg_per_slot, 1),
        peak_hour_rate=round(peak_revenue, 1),
        offpeak_rate=round(offpeak_revenue, 1)
    )

    # --- Performance Metrics ---
    occupied_slots = db.query(func.count(ParkingSlot.parking_slot_id)).filter(
        ParkingSlot.status == "occupied"
    ).scalar() or 0

    occupancy_rate = (occupied_slots / total_slots * 100) if total_slots > 0 else 0
    avg_stay_duration = db.query(func.avg(Reservation.duration)).scalar() or 0

    performance_metrics = PerformanceMetrics(
        utilization_rate=round(occupancy_rate, 1),
        avg_stay_duration=round(avg_stay_duration, 1)
    )

    # --- Reservation Trends (last 7 days) ---
    trends_list = []
    for i in range(7):
        d = today - timedelta(days=i)
        count = db.query(func.count(Reservation.reservation_id)).filter(
            Reservation.date == d
        ).scalar() or 0
        trends_list.append(TrendItem(date=d, reservations_count=count))
    trends = TrendResponse(trends=list(reversed(trends_list)))

    # --- AI Predictions (next 7 days) ---
    predictions = []
    model = load_active_model(db)
    if model:
        for i in range(1, 8):
            future_date = today + timedelta(days=i)
            pred = int(model.predict([[future_date.toordinal()]])[0])
            predictions.append(PredictionResult(date=future_date, predicted_reservations=pred))

    return AnalyticsDashboardResponse(
        revenue_stats=revenue_stats,
        revenue_trends=revenue_trends,
        performance_metrics=performance_metrics,
        trends=trends,
        predictions=predictions
    )


def get_vehicle_visit_frequency(db: Session):
    """
    Returns a dict with visit frequency per vehicle and per day.
    Example:
    {
        "total_vehicles": 50,
        "most_frequent_vehicle": {"vehicle_id": "ABC123", "visits": 12},
        "daily_visits": [{"date": "2025-09-20", "visits": 23}, ...]
    }
    """
    today = date.today()
    last_30_days = today - timedelta(days=30)

    # Get visits in last 30 days
    results = db.query(Reservation.vehicle_id, Reservation.date, func.count(Reservation.reservation_id))\
        .filter(Reservation.date >= last_30_days)\
        .group_by(Reservation.vehicle_id, Reservation.date)\
        .all()

    daily_counts = defaultdict(int)
    vehicle_counts = defaultdict(int)

    for vehicle_id, d, count in results:
        daily_counts[d] += count
        vehicle_counts[vehicle_id] += count

    most_frequent_vehicle = max(vehicle_counts.items(), key=lambda x: x[1], default=(None, 0))

    return {
        "total_vehicles": len(vehicle_counts),
        "most_frequent_vehicle": {"vehicle_id": most_frequent_vehicle[0], "visits": most_frequent_vehicle[1]},
        "daily_visits": [{"date": d, "visits": v} for d, v in sorted(daily_counts.items())]
    }
