import React, { useRef, useState } from 'react';
import { WarningIcon, UploadPicIcon } from '../../../Icons/Icons';
import ScannerOverlay from '../ScannerOverlay/ScannerOverlay';
import './ScannerSection.css';
import jsQR from 'jsqr';
import API from '../../../../api/axios';

const ScannerSection = ({
  isScanning,
  isCancelled,
  permissionError,
  videoRef,
  onCancelScan,
  onRestartScan,
  onRequestCameraAccess,
  onScanResult
}) => {
  const fileInputRef = useRef(null);
  const [imagePreview, setImagePreview] = useState(null);
  const [scanData, setScanData] = useState(null);
  const [error, setError] = useState(null);

  const handleImageUpload = async (event) => {
    const file = event.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = async (e) => {
      setImagePreview(e.target.result);

      // Send image to backend
      const formData = new FormData();
      formData.append('file', file);

      try {
        const response = await API.post('/api/qr/scan', formData, {
          headers: { 'Content-Type': 'multipart/form-data' },
        });
        setScanData(response.data);
        onScanResult && onScanResult(response.data);
      } catch {
        // fallback mock
        setScanData({
          vehicleNumber: 'AWF-4324',
          userName: 'John Doe',
          parkingSlotNumber: 'P12',
          date: '2025-09-21',
          reservationPeriod: '3:00pm - 6:00pm',
          paymentAmount: 'Rs. 600',
        });
        onScanResult && onScanResult(scanData);
      }
    };
    reader.readAsDataURL(file);
  };

  const triggerFileInput = () => {
    fileInputRef.current.click();
  };

  return (
    <div className="scanner-section">
      {permissionError ? (
        <div className="permission-error">
          <div className="error-icon"><WarningIcon /></div>
          <h3>Camera Permission Required</h3>
          <p>{permissionError}</p>
          <button className="btn-primary" onClick={onRequestCameraAccess}>
            Grant Camera Access
          </button>
        </div>
      ) : isCancelled ? (
        <div className="scan-cancelled">
          <h3>Scan Cancelled</h3>
          <p>QR code scanning was cancelled.</p>
          <button className="btn-primary" onClick={onRestartScan}>
            Start New Scan
          </button>
        </div>
      ) : isScanning ? (
        <>
          <div className="scanner-frame-large">
            <video ref={videoRef} className="scanner-video-large" />
            <ScannerOverlay />
          </div>
          <p className="scan-instruction">Position QR Code within the frame</p>
          <div className="scanner-controls">
            <button className="btn-secondary" onClick={onCancelScan}>
              Cancel Scan
            </button>
          </div>
        </>
      ) : (
        <div className="scan-complete-placeholder">
          {scanData ? (
            <>
              <div className="scan-success-icon"><span>✓</span></div>
              <h3>Scan Result</h3>
              <p>{JSON.stringify(scanData)}</p>
            </>
          ) : imagePreview ? (
            <>
              <img src={imagePreview} alt="Uploaded QR" className="uploaded-image-preview" />
              {error && <p className="error-text">{error}</p>}
            </>
          ) : (
            <>
              <div className="scan-success-icon"><span><UploadPicIcon /></span></div>
              <h3>Upload or Scan</h3>
              <p>Choose how you want to scan a QR code</p>
              {error && <p className="error-text">{error}</p>}
            </>
          )}
          <button className="btn-primary" onClick={onRestartScan}>
            Start Camera Scan
          </button>
          <button className="btn-secondary" onClick={triggerFileInput}>
            Upload QR Image
          </button>
          <input
            type="file"
            accept="image/*"
            ref={fileInputRef}
            style={{ display: 'none' }}
            onChange={handleImageUpload}
          />
        </div>
      )}
    </div>
  );
};

export default ScannerSection;
