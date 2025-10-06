from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import Base, engine

# Import routers
from app.routes import (
    contact_router,
    auth_router,
    dashboard_router,
    qr_router,
    reservation_router,
    parking_router,
    vehicle_router,
    waitlist_router,
    cancellation_router,
    analytics_router,
    notification_router,
    user_router
)

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="ParkFlow API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(contact_router)
app.include_router(auth_router)
app.include_router(qr_router, prefix="/api/qr", tags=["QR"])
app.include_router(reservation_router, prefix="/api/reservations", tags=["Reservations"])
app.include_router(vehicle_router, prefix="/api/vehicles", tags=["Vehicles"])
app.include_router(parking_router, prefix="/api/parking", tags=["Parking"])
app.include_router(waitlist_router, prefix="/api/waitlist", tags=["Waitlist"])
app.include_router(cancellation_router, prefix="/api/cancellations", tags=["Cancellations"])
app.include_router(analytics_router, prefix="/api/analytics", tags=["Analytics"])
app.include_router(notification_router)
app.include_router(user_router)
app.include_router(dashboard_router)


# Attach database event listeners at startup
@app.on_event("startup")
async def startup_event():
    from app.utils.db_events import setup_database_events
    setup_database_events()
    print("[STARTUP] Database event listeners attached successfully.")


@app.get("/")
def root():
    return {"message": "Backend is running successfully"}
