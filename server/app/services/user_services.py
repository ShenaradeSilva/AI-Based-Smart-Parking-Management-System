import bcrypt
from sqlalchemy.orm import Session
from sqlalchemy import or_
from ..models.user_model import User, UserRole, UserStatus
from typing import List, Optional

# User Profile
def get_user_by_id(db: Session, user_id: int):
    return db.query(User).filter(User.user_id == user_id).first()


# Update user profile (for self)
def update_user_profile(
        db: Session,
        user_id: int,
        name: str = None,
        email: str = None,
        mobile: str = None,
        password: str = None,
        profile_picture: bytes = None,
        remove_picture: bool = False
):
    user = db.query(User).filter(User.user_id == user_id).first()
    if not user:
        return None

    if name:
        user.name = name.strip()

    if email:
        user.email = email.strip()  # <-- add this line

    if mobile:
        # Remove country code if it already exists to prevent duplication
        if mobile.startswith("+94"):
            mobile = mobile[3:]  # remove +94
        user.phone = mobile.strip()

    if password:
        hashed_password = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
        user.password_hash = hashed_password

    if profile_picture:
        user.profile_picture = profile_picture
    if remove_picture:
        user.profile_picture = None

    db.commit()
    db.refresh(user)
    return user


# User management
# Get all users (with optional search/filter)
def get_all_users(db: Session, search: Optional[str] = None):
    query = db.query(User)
    if search:
        query = query.filter(
            User.name.ilike(f"%{search}%") | User.email.ilike(f"%{search}%")
        )
    users = query.all()

    result = []
    for u in users:
        result.append({
            "user_id": u.user_id,
            "name": u.name,
            "email": u.email,
            "phone": u.phone,
            "role": u.role.value if u.role else "driver",
            "status": u.status,
            "profilePicture": u.profile_picture,
            "created_at": u.created_at.isoformat() if u.created_at else None,  # ✅ Use created_at key
        })
    return result



# Create new user (admin)
def create_user(db: Session, name: str, email: str, password: str, role: UserRole, phone: str = None):
    hashed_password = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")
    new_user = User(
        name=name.strip(),
        email=email.strip(),
        password_hash=hashed_password,
        phone=phone.strip() if phone else None,
        role=role,
        status=UserStatus.active
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user


# Admin update user
def admin_update_user(db: Session, user_id: int, role: UserRole = None, status: UserStatus = None):
    user = get_user_by_id(db, user_id)
    if not user:
        return None

    if role:
        user.role = role
    if status:
        user.status = status

    db.commit()
    db.refresh(user)
    return user


# Delete user
from ..models.waitlist_model import Waitlist  # make sure this import exists

def delete_user(db: Session, user_id: int):
    user = db.query(User).filter(User.user_id == user_id).first()
    if not user:
        return False

    # If you have relationships with cascade='all, delete-orphan', SQLAlchemy should delete automatically
    db.delete(user)
    db.commit()
    return True


# Toggle active/inactive status
def toggle_user_status(db: Session, user_id: int):
    user = get_user_by_id(db, user_id)
    if not user:
        return None
    user.status = UserStatus.inactive if user.status == UserStatus.active else UserStatus.active
    db.commit()
    db.refresh(user)
    return user
