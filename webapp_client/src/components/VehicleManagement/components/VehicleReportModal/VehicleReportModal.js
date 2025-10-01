import React from 'react';
import './VehicleReportModal.css';
import { CloseIcon } from '../../../Icons/Icons';

const VehicleReportModal = ({ vehicles, onClose, onExport }) => {
  return (
    <div className="modal-overlay">
      <div className="modal-content report-modal-content">
        <div className="modal-header">
          <h3>Registered Vehicles Report</h3>
          <button className="close-btn" onClick={onClose}><CloseIcon /></button>
        </div>
        <div className="report-table-container">
          <table className="report-table">
            <thead>
              <tr>
                <th>Plate</th>
                <th>Type</th>
                <th>Owner</th>
                <th>Registered</th>
              </tr>
            </thead>
            <tbody>
              {vehicles.map(v => (
                <tr key={v.vehicle_id}>
                  <td>{v.plateNumber}</td>
                  <td>{v.type}</td>
                  <td>{v.owner}</td>
                  <td>{v.registeredDate}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="modal-buttons">
          <button className="btn btn-secondary" onClick={onClose}>Close</button>
          <button className="btn btn-primary" onClick={onExport}>Export CSV</button>
        </div>
      </div>
    </div>
  );
};

export default VehicleReportModal;
