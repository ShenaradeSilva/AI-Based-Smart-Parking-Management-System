from pydantic import BaseModel
from datetime import date
from typing import List, Dict


class RevenueStats(BaseModel):
    today: float
    week: float
    month: float
    growth_rate: float  # percentage


class RevenueTrends(BaseModel):
    avg_per_slot_day: float
    peak_hour_rate: float
    offpeak_rate: float


class PerformanceMetrics(BaseModel):
    utilization_rate: float  # percentage
    avg_stay_duration: float  # hours


class TrendItem(BaseModel):
    date: date
    reservations_count: int


class TrendResponse(BaseModel):
    trends: List[TrendItem]


class PredictionResult(BaseModel):
    date: date
    predicted_reservations: int


class AnalyticsDashboardResponse(BaseModel):
    revenue_stats: RevenueStats
    revenue_trends: RevenueTrends
    performance_metrics: PerformanceMetrics
    trends: TrendResponse
    predictions: List[PredictionResult]

    class Config:
        from_attributes = True  # Pydantic V2 compatible


class PeakTimeResponse(BaseModel):
    historical: Dict[str, str]      # e.g., {"weekdays": "8-10AM", "weekend": "12-6PM"}
    highest_demand: str             # e.g., "Friday 5:30 PM (95% occupancy)"
    ai_predictions: Dict[str, str]  # e.g., {"tomorrow_peak": "2-4 PM", "expected": "85% occupancy"}
    weekly_trend: str               # e.g., "Increasing demand on Wednesdays"
    recommendation: str             # e.g., "Dynamic pricing implementation"
    capacity_alert: str             # e.g., "Saturday expected to reach 100%"
    suggestion: str                 # e.g., "Open additional temporary slots"
