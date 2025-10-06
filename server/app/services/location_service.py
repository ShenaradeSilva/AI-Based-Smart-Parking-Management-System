from sqlalchemy.orm import Session
from sqlalchemy import or_
import requests
from ..models.location_model import Location
from ..schemas.location_schema import LocationCreate, LocationResponse
from ..config import GOOGLE_MAPS_API_KEY, GEOCODE_URL

# --------------------------
# Google Maps Helper
# --------------------------
def geocode_address(address: str):
    """
    Get latitude & longitude using Google Maps API.
    Returns (lat, lng) or (None, None) if API key not set or geocoding fails.
    """
    if not GOOGLE_MAPS_API_KEY:
        return None, None
    params = {"address": address, "key": GOOGLE_MAPS_API_KEY}
    try:
        response = requests.get(GEOCODE_URL, params=params, timeout=5)
        response.raise_for_status()
        result = response.json()
        if result.get("status") == "OK" and result.get("results"):
            loc = result["results"][0]["geometry"]["location"]
            return loc["lat"], loc["lng"]
    except requests.RequestException:
        pass
    return None, None

# --------------------------
# Admin Services
# --------------------------
def create_location(db: Session, location: LocationCreate, user_id: int):
    lat, lng = geocode_address(location.address)
    new_location = Location(
        name=location.name,
        address=location.address,
        hourly_rate=location.hourly_rate,
        lat=lat,
        lng=lng,
        created_by=user_id
    )
    db.add(new_location)
    db.commit()
    db.refresh(new_location)
    return new_location

# --------------------------
# User Services
# --------------------------
def get_all_locations(db: Session):
    return db.query(Location).order_by(Location.created_at.desc()).all()

def search_locations(db: Session, query: str):
    return db.query(Location).filter(
        or_(
            Location.name.ilike(f"%{query}%"),
            Location.address.ilike(f"%{query}%")
        )
    ).all()
