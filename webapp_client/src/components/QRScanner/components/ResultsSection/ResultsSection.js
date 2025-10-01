import React from 'react';
import './ResultsSection.css';

const ResultsSection = ({ scanResult, permissionError, isCancelled, onRestartScan }) => {
  return (
    <div className="results-section">
      {scanResult ? (
        <div className="scan-results">
          <h3>Scan Results</h3>
          <div className="result-details">
            <div className="result-row">
              <span className="label">Vehicle Number</span>
              <span className="value">{scanResult.vehicleNumber || "N/A"}</span>
            </div>
            <div className="result-row">
              <span className="label">User Name</span>
              <span className="value">{scanResult.userName || "N/A"}</span>
            </div>
            <div className="result-row">
              <span className="label">Parking Slot</span>
              <span className="value">{scanResult.parkingSlotNumber || "N/A"}</span>
            </div>
            <div className="result-row">
              <span className="label">Date</span>
              <span className="value">{scanResult.date || "N/A"}</span>
            </div>
            <div className="result-row">
              <span className="label">Reservation Period</span>
              <span className="value">{scanResult.reservationPeriod || "N/A"}</span>
            </div>
            {scanResult.rawData && (
              <div className="result-row">
                <span className="label">Raw Data</span>
                <span className="value">{scanResult.rawData}</span>
              </div>
            )}
          </div>

          <div className="payment-section">
            <h3>Payment Amount</h3>
            <div className="payment-amount">{scanResult.paymentAmount || "Pending"}</div>
          </div>

          {onRestartScan && (
            <button className="restart-button" onClick={onRestartScan}>
              Scan Another QR
            </button>
          )}
        </div>
      ) : permissionError ? (
        <div className="no-results">
          <h3>Camera Access Needed</h3>
          <p>Please grant camera permissions to scan QR codes.</p>
        </div>
      ) : isCancelled ? (
        <div className="no-results">
          <h3>No Results</h3>
          <p>Scan was cancelled before a QR code was detected.</p>
        </div>
      ) : (
        <div className="no-results">
          <h3>Waiting for Scan</h3>
          <p>Scan a QR code to see the results here.</p>
        </div>
      )}
    </div>
  );
};

export default ResultsSection;
