import React from 'react';
import './ScannerOverlay.css';

const ScannerOverlay = () => {
  return (
    <div className="scan-overlay">
      <div className="corner top-left"></div>
      <div className="corner top-right"></div>
      <div className="corner bottom-left"></div>
      <div className="corner bottom-right"></div>
      <div className="scan-line"></div>
    </div>
  );
};

export default ScannerOverlay;