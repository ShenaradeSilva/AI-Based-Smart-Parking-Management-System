from sqlalchemy.orm import Session
from ..models.notification_model import Notification, NotificationStatus
from ..models.user_model import User
from ..models.vehicle_model import Vehicle
from ..models.parkingslot_model import ParkingSlot
from ..models.reservation_model import Reservation
from datetime import date


# -------------------------
# Individual metric services
# -------------------------

def get_total_users(db: Session) -> int:
    return db.query(User).count()


def get_registered_vehicles(db: Session) -> int:
    return db.query(Vehicle).count()


def get_notifications(db: Session) -> dict:
    total = db.query(Notification).count()
    unread = db.query(Notification).filter(
        Notification.status == NotificationStatus.unread
    ).count()
    return {"total": total, "unread": unread}


def get_occupancy(db: Session) -> dict:
    total_slots = db.query(ParkingSlot).count()
    occupied_slots = db.query(Reservation).filter(
        Reservation.status.in_(["active", "confirmed"]),
        Reservation.date == date.today()
    ).count()

    occupancy_rate = int((occupied_slots / total_slots) * 100) if total_slots else 0
    available_slots = total_slots - occupied_slots if total_slots else 0

    return {
        "totalSlots": total_slots,
        "occupiedSlots": occupied_slots,
        "availableSlots": available_slots,
        "occupancyRate": occupancy_rate,
    }


def get_uptime_status(total_users: int, total_vehicles: int, total_slots: int) -> str:
    return "Online" if total_slots > 0 and total_vehicles > 0 and total_users > 0 else "Degraded"


# -------------------------
# Dashboard aggregator
# -------------------------

def get_dashboard_data(db: Session) -> dict:
    total_users = get_total_users(db)
    total_vehicles = get_registered_vehicles(db)
    notifications = get_notifications(db)
    occupancy = get_occupancy(db)

    uptime_status = get_uptime_status(
        total_users=total_users,
        total_vehicles=total_vehicles,
        total_slots=occupancy["totalSlots"]
    )

    return {
        "totalUsers": total_users,
        "registeredVehicles": total_vehicles,
        "totalNotifications": notifications["total"],
        "unreadNotifications": notifications["unread"],
        "occupancyRate": occupancy["occupancyRate"],
        "uptimeStatus": uptime_status,
        "bookings": occupancy["occupiedSlots"],
        "occupiedSlots": occupancy["occupiedSlots"],
        "availableSlots": occupancy["availableSlots"],
        "alerts": notifications["unread"]  # reuse unread notifications
    }
