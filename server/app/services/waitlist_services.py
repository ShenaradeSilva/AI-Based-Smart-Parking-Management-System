from sqlalchemy.orm import Session
from ..models.waitlist_model import Waitlist
from ..schemas.waitlist_schema import WaitlistCreate, WaitlistUpdate
from datetime import datetime


def get_waitlist(db: Session):
    return db.query(Waitlist).order_by(Waitlist.priority.desc(), Waitlist.requested_at.asc()).all()


def create_waitlist(db: Session, waitlist: WaitlistCreate):
    db_waitlist = Waitlist(**waitlist.dict())
    db.add(db_waitlist)
    db.commit()
    db.refresh(db_waitlist)
    return db_waitlist


def notify_driver(db: Session, waitlist_id: int):
    waitlist_entry = db.query(Waitlist).filter(Waitlist.waitlist_id == waitlist_id).first()
    if not waitlist_entry:
        return None
    waitlist_entry.status = "notified"
    waitlist_entry.notified_at = datetime.utcnow()
    db.commit()
    db.refresh(waitlist_entry)
    # TODO: send push notification to mobile app here
    return waitlist_entry


def remove_waitlist(db: Session, waitlist_id: int):
    waitlist_entry = db.query(Waitlist).filter(Waitlist.waitlist_id == waitlist_id).first()
    if not waitlist_entry:
        return None
    waitlist_entry.status = "cancelled"
    db.commit()
    return waitlist_entry
