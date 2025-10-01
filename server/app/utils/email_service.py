# app/utils/email_service.py
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import threading
from ..config import EMAIL_FROM, EMAIL_PASSWORD, SMTP_SERVER, SMTP_PORT


def send_email(to_email: str, subject: str, body: str):
    """
    Send email using SMTP
    """
    try:
        # Create message
        msg = MIMEMultipart()
        msg['From'] = EMAIL_FROM
        msg['To'] = to_email
        msg['Subject'] = subject

        msg.attach(MIMEText(body, 'plain'))

        # Create server connection and send
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(EMAIL_FROM, EMAIL_PASSWORD)
        text = msg.as_string()
        server.sendmail(EMAIL_FROM, to_email, text)
        server.quit()

        print(f"Email sent to {to_email}")
        return True

    except Exception as e:
        print(f"Failed to send email to {to_email}: {e}")
        return False


def send_email_async(to_email: str, subject: str, body: str):
    """
    Send email in background thread
    """
    try:
        email_thread = threading.Thread(
            target=send_email,
            args=(to_email, subject, body),
            daemon=True
        )
        email_thread.start()
        print(f"Email sending started for {to_email}")
        return True
    except Exception as e:
        print(f"Failed to start email thread: {e}")
        return False


# Email templates
def send_welcome_email_driver(name: str, email: str, phone: str, vehicle_number: str):
    """
    Send welcome email to driver
    """
    subject = "Welcome to ParkFlow"
    body = f"""Hello {name},

Welcome to ParkFlow! Your driver account has been created successfully.

Account Details:
• Name: {name}
• Email: {email}
• Phone: {phone}
• Vehicle: {vehicle_number}

You can now book parking spots conveniently through our mobile app.

Happy Parking!
The ParkFlow Team"""

    return send_email_async(email, subject, body)


def send_welcome_email_admin(name: str, email: str):
    """
    Send welcome email to admin
    """
    subject = "Welcome to ParkFlow Admin"
    body = f"""Hello {name},

Your ParkFlow admin account has been created successfully.

You now have access to the admin dashboard where you can:
• Manage parking spots
• View analytics
• Manage users and vehicles
• Monitor reservations

Login to get started!

Best regards,
The ParkFlow Team"""

    return send_email_async(email, subject, body)


def send_password_reset_code(name: str, email: str, code: str):
    """
    Send password reset verification code
    """
    subject = "ParkFlow - Password Reset Verification Code"
    body = f"""Hello {name},

You requested a password reset for your ParkFlow account.

Your verification code is: {code}

This code will expire in 10 minutes.

If you didn't request this reset, please ignore this email.

Best regards,
ParkFlow Team"""

    return send_email_async(email, subject, body)


def send_password_reset_success(name: str, email: str):
    """
    Send password reset success notification
    """
    subject = "ParkFlow - Password Reset Successful"
    body = f"""Hello {name},

Your ParkFlow password has been successfully reset.

If you did not make this change, please contact support immediately.

Best regards,
ParkFlow Team"""

    return send_email_async(email, subject, body)