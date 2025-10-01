from sqlalchemy.orm import Session
from datetime import datetime
from fastapi import HTTPException
from ..models.qrcode_model import QRCode
from ..schemas.qr_schema import QRScanResult


def scan_qr_code(db: Session, qr_code_data: str, scan_type: str = "entry") -> QRScanResult:
    qr = db.query(QRCode).filter(QRCode.code_data == qr_code_data).first()
    if not qr:
        raise HTTPException(status_code=404, detail="QR code not found")

    reservation = qr.reservation
    if not reservation:
        raise HTTPException(status_code=404, detail="Associated reservation not found")

    now = datetime.utcnow()

    # Get hourly rate from the reservation's location
    location = reservation.parking_slot.location if reservation.parking_slot else None
    if not location:
        raise HTTPException(status_code=400, detail="Reservation location not found")
    hourly_rate = location.hourly_rate or 200  # fallback to 200 if not set

    if scan_type == "entry":
        if reservation.actual_entry:
            raise HTTPException(status_code=400, detail="Entry already scanned")
        reservation.actual_entry = now
        reservation.status = "active"
        db.commit()
        payment_amount = None
    elif scan_type == "exit":
        if not reservation.actual_entry:
            raise HTTPException(status_code=400, detail="Cannot exit without entry scan")
        if reservation.actual_exit:
            raise HTTPException(status_code=400, detail="Exit already scanned")
        reservation.actual_exit = now
        reservation.status = "completed"

        # Calculate payment based on actual duration and location rate
        duration_hours = (reservation.actual_exit - reservation.actual_entry).total_seconds() / 3600
        payment_amount = round(duration_hours * hourly_rate, 2)
        db.commit()
    else:
        raise HTTPException(status_code=400, detail="Invalid scan type")

    return QRScanResult(
        vehicleNumber=reservation.vehicle.plate_number if reservation.vehicle else "N/A",
        userName=reservation.user.name if reservation.user else "N/A",
        parkingSlotNumber=reservation.parking_slot.slot_number if reservation.parking_slot else "N/A",
        date=reservation.date.strftime("%Y-%m-%d"),
        reservationPeriod=f"{reservation.start_time.strftime('%I:%M %p')} - {reservation.end_time.strftime('%I:%M %p')}",
        paymentAmount=f"Rs. {payment_amount}" if payment_amount else "Pending",
        rawData=qr.code_data
    )
