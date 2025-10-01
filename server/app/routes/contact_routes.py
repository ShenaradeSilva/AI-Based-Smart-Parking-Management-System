# app/routes/contact_routes.py
from fastapi import APIRouter, HTTPException
from ..schemas.contact_schema import ContactMessage
from ..services.contact_services import send_contact_email
from ..services.notification_services import create_notification
from ..database import get_db

router = APIRouter()


@router.post("/send")
def send_message(contact: ContactMessage):
    db = next(get_db())
    try:
        # Send email to admin
        send_contact_email(contact)

        # Create notification for admin
        create_notification(
            db,
            f"New contact message from {contact.name} ({contact.email}): {contact.subject}",
            "info",
            user_id=1  # assuming admin user_id=1; adjust if multiple admins
        )

        return {"status": "success", "message": "Email sent successfully!"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send email: {str(e)}")
