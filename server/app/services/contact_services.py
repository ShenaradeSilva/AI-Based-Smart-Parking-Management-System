from ..schemas.contact_schema import ContactMessage
from ..utils.email_service import send_email_async

ADMIN_EMAIL = "parkflowteam@gmail.com"  # your admin inbox


def send_contact_email(contact: ContactMessage):
    """
    Format and send contact form message to admin
    """
    subject = f"Contact Form: {contact.subject}"
    body = f"""
    You have received a new message from ParkFlow Contact Form:

    Name: {contact.name}
    Email: {contact.email}

    Message:
    {contact.message}
    """

    return send_email_async(ADMIN_EMAIL, subject, body)
