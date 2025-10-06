from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from ..schemas.location_schema import LocationCreate, LocationResponse
from ..services.location_services import create_location as svc_create_location, get_all_locations as svc_get_all_locations, search_locations as svc_search_locations
from ..database import get_db
from ..services.user_services import get_current_user

router = APIRouter(prefix="/api/locations", tags=["Locations"])


# Admin Route: Create Location
@router.post("/create", response_model=LocationResponse)
def create_location(
    location: LocationCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    if current_user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Only admin can create locations")
    return svc_create_location(db, location, current_user["user_id"])


# User Route: List All Locations
@router.get("/list", response_model=List[LocationResponse])
def list_locations(db: Session = Depends(get_db)):
    return svc_get_all_locations(db)


# User Route: Search Locations
@router.get("/search", response_model=List[LocationResponse])
def search_locations(query: str = Query(..., min_length=1), db: Session = Depends(get_db)):
    results = svc_search_locations(db, query)
    if not results:
        raise HTTPException(status_code=404, detail="No locations found")
    return results
