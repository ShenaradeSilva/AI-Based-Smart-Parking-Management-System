from sqlalchemy.orm import Session
import requests
from ..models.location_model import Location
from ..schemas.location_schema import LocationCreate, LocationResponse
from ..config import GOOGLE_MAPS_API_KEY, GEOCODE_URL


# Google Maps Helper
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


# Admin Services
def create_location(db: Session, location: LocationCreate, user_id: int):
    # Create location in database
    new_location = Location(
        name=location.name,
        address=location.address,
        hourly_rate=location.hourly_rate,
        created_by=user_id
    )
    db.add(new_location)
    db.commit()
    db.refresh(new_location)

    # Get lat/lng from Google Maps API (not stored in DB)
    lat, lng = geocode_address(location.address)

    # Return response with coordinates
    return LocationResponse(
        location_id=new_location.location_id,
        name=new_location.name,
        address=new_location.address,
        hourly_rate=float(new_location.hourly_rate),
        created_at=new_location.created_at,
        created_by=new_location.created_by,
        lat=lat,
        lng=lng
    )


# User Services
def get_all_locations(db: Session):
    locations = db.query(Location).order_by(Location.created_at.desc()).all()
    # Optionally, include lat/lng in response by geocoding (or just leave None)
    response = []
    for loc in locations:
        lat, lng = geocode_address(loc.address)
        response.append(LocationResponse(
            location_id=loc.location_id,
            name=loc.name,
            address=loc.address,
            hourly_rate=float(loc.hourly_rate),
            created_at=loc.created_at,
            created_by=loc.created_by,
            lat=lat,
            lng=lng
        ))
    return response


def search_locations(db: Session, query: str):
    results = db.query(Location).filter(
        Location.name.ilike(f"%{query}%") | Location.address.ilike(f"%{query}%")
    ).all()
    response = []
    for loc in results:
        lat, lng = geocode_address(loc.address)
        response.append(LocationResponse(
            location_id=loc.location_id,
            name=loc.name,
            address=loc.address,
            hourly_rate=float(loc.hourly_rate),
            created_at=loc.created_at,
            created_by=loc.created_by,
            lat=lat,
            lng=lng
        ))
    return response
