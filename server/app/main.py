from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import(
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
from app.database import Base, engine
from .database import setup_database_events

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="ParkFlow API", version="1.0.0")

# origins = ["http://localhost:3000", "http://127.0.0.1:3000"]
origins = ["*"]


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(contact_router, prefix="/api/contact", tags=["Contact"])
app.include_router(auth_router)
app.include_router(qr_router, prefix="/api/qr", tags=["QR"])
app.include_router(reservation_router, prefix="/api/reservations", tags=["Reservations"])
app.include_router(vehicle_router, prefix="/api/vehicles", tags=["Vehicles"])
app.include_router(parking_router, prefix="/api/parking", tags=["Parking"])
app.include_router(waitlist_router, prefix="/api/waitlist", tags=["Waitlist"])
app.include_router(cancellation_router, prefix="/api/cancellations", tags=["Cancellations"])
app.include_router(analytics_router, prefix="/api/analytics", tags=["Analytics"])
app.include_router(notification_router, prefix="/api")  # Fixed prefix
app.include_router(user_router)
app.include_router(dashboard_router)

try:
    from .routes import user_router
    print("user_router imported successfully")
    print(f"user_router type: {type(user_router)}")
    print(f"user_router prefix: {user_router.prefix}")
    print(f"user_router routes: {user_router.routes}")
except ImportError as e:
    print(f"Error importing user_router: {e}")
    # Try alternative import
    try:
        from .routes.user_routes import router as user_router
        print("user_router imported via alternative method")
    except ImportError as e2:
        print(f"Alternative import also failed: {e2}")

# Include user_router with debug info
try:
    print("Including user_router with prefix /api/users")
    app.include_router(user_router, prefix="/api/users", tags=["Users"])
    print("user_router included successfully")
except Exception as e:
    print(f"Error including user_router: {e}")


@app.on_event("startup")
async def startup_event():
    print("=== REGISTERED ROUTES ===")
    for route in app.routes:
        if hasattr(route, "methods") and hasattr(route, "path"):
            print(f"{list(route.methods)} {route.path}")

@app.get("/")
def root():
    return {"message": "Backend is running successfully"}

# Test endpoint to verify users route
@app.get("/api/users/debug")
def users_debug():
    return {"message": "Users debug endpoint working"}