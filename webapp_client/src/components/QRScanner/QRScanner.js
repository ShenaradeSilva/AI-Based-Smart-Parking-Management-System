import React, { useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import './QRScanner.css';
import ScannerSection from './components/ScannerSection/ScannerSection';
import ResultsSection from './components/ResultsSection/ResultsSection';
import HeaderPages from '../Common/HeaderPages';
import { validateImageFile } from '../../utils/validations';
import API from '../../api/axios';

const QRScanner = () => {
  const navigate = useNavigate();
  const [scanResult, setScanResult] = useState(null);
  const [isScanning, setIsScanning] = useState(false);
  const [isCancelled, setIsCancelled] = useState(false);
  const [permissionError, setPermissionError] = useState(null);
  const [uploadError, setUploadError] = useState(null);
  const [showChoice, setShowChoice] = useState(true);

  const videoRef = useRef(null);
  const scannerRef = useRef(null);
  const fileInputRef = useRef(null);

  const handleBackToDashboard = () => navigate('/dashboard');

  const handleStartCameraScan = () => {
    setShowChoice(false);
    setUploadError(null);
    requestCameraAccess();
  };

  const handleUploadClick = () => {
    setUploadError(null);
    fileInputRef.current.click();
  };

  const handleFileUpload = async (event) => {
    const file = event.target.files[0];
    if (!file) return;

    const errorMsg = validateImageFile(file);
    if (errorMsg) {
      setUploadError(errorMsg);
      return;
    }

    setUploadError(null);

    const formData = new FormData();
    formData.append('file', file);

    try {
      const response = await API.post('/api/qr/scan', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });
      setScanResult(response.data);
    } catch (err) {
      console.error('QR scan error:', err);
      // Fallback mock data if backend fails
      setScanResult({
        // rawData: reader.result,
        vehicleNumber: 'AWF-4324',
        userName: 'John Doe',
        parkingSlotNumber: 'P12',
        date: '2025-09-21',
        reservationPeriod: '3:00pm - 6:00pm',
        paymentAmount: 'Rs. 600',
      });
    }
  };

  const requestCameraAccess = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: 'environment' },
      });
      stream.getTracks().forEach(track => track.stop());
      setPermissionError(null);
      setIsScanning(true);
    } catch (error) {
      console.error('Camera access error:', error);
      setPermissionError('Camera access denied.');
    }
  };

  const handleCancelScan = () => {
    setIsCancelled(true);
    setIsScanning(false);
  };

  const restartScan = () => {
    setScanResult(null);
    setPermissionError(null);
    setUploadError(null);
    setIsCancelled(false);
    setShowChoice(true);
    setIsScanning(false);
  };

  return (
    <div className="qr-scanner-container">
      <HeaderPages title="QR Scan Interface" onBack={handleBackToDashboard} />

      <div className="scanner-layout">
        <div className="scanner-container">
          {showChoice ? (
            <div className="scan-choice-container">
              <div className="scan-choice-buttons">
                <button className="btn-primary" onClick={handleStartCameraScan}>
                  Start Camera Scan
                </button>
                <button className="btn-secondary" onClick={handleUploadClick}>
                  Upload QR Image
                </button>
                {uploadError && <div className="upload-error">{uploadError}</div>}
              </div>
            </div>
          ) : (
            <ScannerSection
              isScanning={isScanning}
              isCancelled={isCancelled}
              permissionError={permissionError}
              videoRef={videoRef}
              onCancelScan={handleCancelScan}
              onRestartScan={restartScan}
              onScanResult={setScanResult}
            />
          )}
        </div>

        <ResultsSection
          scanResult={scanResult}
          permissionError={permissionError}
          isCancelled={isCancelled}
          onRestartScan={restartScan}
        />
      </div>

      <input
        type="file"
        accept=".png, .jpg, .jpeg, image/png, image/jpg, image/jpeg"
        ref={fileInputRef}
        style={{ display: 'none' }}
        onChange={handleFileUpload}
      />
    </div>
  );
};

export default QRScanner;
