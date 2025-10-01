from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, Query
from sqlalchemy.orm import Session
from ..database import get_db
from ..services.qr_services import scan_qr_code
from ..services.notification_services import create_notification
from ..schemas.qr_schema import QRScanResult
import io
from PIL import Image
import pyzbar.pyzbar as pyzbar

router = APIRouter(prefix="/api/qr", tags=["QR"])


@router.get("/scan/{qr_code_data}", response_model=QRScanResult)
def scan_qr(qr_code_data: str, scan_type: str = Query("entry"), db: Session = Depends(get_db)):
    """
    Scan QR code from camera.
    scan_type: "entry" or "exit"
    """
    result = scan_qr_code(db, qr_code_data, scan_type)

    # Notification
    create_notification(
        db,
        f"QR code scanned for {scan_type}: {qr_code_data}",
        "info",
        user_id=result.user_id if hasattr(result, "user_id") else 1
    )
    return result


@router.post("/scan/upload", response_model=QRScanResult)
async def scan_qr_upload(
    file: UploadFile = File(...),
    scan_type: str = Query("entry"),
    db: Session = Depends(get_db)
):
    """
    Scan QR code from uploaded image.
    """
    try:
        image = Image.open(io.BytesIO(await file.read()))
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid image file")

    decoded_objects = pyzbar.decode(image)
    if not decoded_objects:
        raise HTTPException(status_code=404, detail="No QR code detected in the image")

    qr_code_data = decoded_objects[0].data.decode("utf-8")
    result = scan_qr_code(db, qr_code_data, scan_type)

    # Notification
    create_notification(
        db,
        f"QR code uploaded and scanned for {scan_type}: {qr_code_data}",
        "info",
        user_id=result.user_id if hasattr(result, "user_id") else 1
    )
    return result
