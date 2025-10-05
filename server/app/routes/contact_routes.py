from fastapi import APIRouter, HTTPException
from ..schemas.contact_schema import ContactMessage
from ..services.contact_services import send_contact_email

router = APIRouter(prefix="/api/contact", tags=["Contact"])


@router.post("/send")
def send_message(contact: ContactMessage):
    try:
        send_contact_email(contact)
        return {"status": "success", "message": "Email sent successfully!"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send email: {str(e)}")
