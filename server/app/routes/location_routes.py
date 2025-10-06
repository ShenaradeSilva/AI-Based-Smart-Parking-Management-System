from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from ..schemas.location_schema import LocationCreate, LocationResponse
from ..services import location_service
from ..database import get_db
from ..services.user_services import get_current_user

router = APIRouter(prefix="/api/locations", tags=["Locations"])

# --------------------------
# Admin Route: Create Location
# --------------------------
@router.post("/create", response_model=LocationResponse)
def create_location(location: LocationCreate, db: Session = Depends(get_db), current_user: dict = Depends(get_current_user)):
    if current_user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Only admin can create locations")
    return location_service.create_location(db, location, current_user["user_id"])

# --------------------------
# User Route: List All Locations
# --------------------------
@router.get("/list", response_model=List[LocationResponse])
def get_locations(db: Session = Depends(get_db)):
    return location_service.get_all_locations(db)

# --------------------------
# User Route: Search Locations
# --------------------------
@router.get("/search", response_model=List[LocationResponse])
def search_locations(query: str = Query(..., min_length=1), db: Session = Depends(get_db)):
    results = location_service.search_locations(db, query)
    if not results:
        raise HTTPException(status_code=404, detail="No locations found")
    return results
