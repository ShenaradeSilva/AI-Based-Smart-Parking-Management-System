from ..schemas.contact_schema import ContactMessage
from ..utils.email_utils import send_email

GMAIL_EMAIL = "parkflow.info@gmail.com"  # sending address


def send_contact_email(contact: ContactMessage):
    subject = f"Contact Form: {contact.subject}"
    body = f"Name: {contact.name}\nEmail: {contact.email}\n\nMessage:\n{contact.message}"

    send_email(GMAIL_EMAIL, subject, body)  # send to yourself
