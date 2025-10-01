import React, { useState, useEffect } from 'react';
import './VehicleModal.css';

const VehicleModal = ({ vehicle, vehicleTypes = [], onClose, onSave, isEditing }) => {
  const [formData, setFormData] = useState({ plateNumber: '', type: '', owner: '' });

  useEffect(() => {
    if (vehicle) {
      setFormData({
        plateNumber: vehicle.plateNumber || '',
        type: vehicle.type || '',
        owner: vehicle.owner || ''
      });
    } else {
      setFormData({ plateNumber: '', type: '', owner: '' });
    }
  }, [vehicle]);

  const handleInputChange = e => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = e => {
    e.preventDefault();
    onSave(formData);
  };

  return (
    <div className="modal-overlay">
      <div className="modal">
        <div className="modal-header">
          <h3>{isEditing ? 'Edit Vehicle' : 'Register Vehicle'}</h3>
          <button className="modal-close" onClick={onClose}>×</button>
        </div>
        <form onSubmit={handleSubmit} className="modal-form">
          <div className="form-group">
            <label htmlFor="plateNumber">Plate Number</label>
            <input
              type="text"
              id="plateNumber"
              name="plateNumber"
              value={formData.plateNumber}
              onChange={handleInputChange}
              required
              readOnly={!!formData.plateNumber}  // <--- read-only if ANPR filled it
            />
          </div>
          <div className="form-group">
            <label htmlFor="type">Vehicle Type</label>
            <select
              id="type"
              name="type"
              value={formData.type}
              onChange={handleInputChange}
              required
            >
              <option value="">Select Type</option>
              {vehicleTypes.map(type => (
                <option key={type} value={type}>{type}</option>
              ))}
            </select>
          </div>
          <div className="form-group">
            <label htmlFor="owner">Owner Name</label>
            <input
              type="text"
              id="owner"
              name="owner"
              value={formData.owner}
              onChange={handleInputChange}
              required
            />
          </div>
          <div className="modal-actions">
            <button type="button" onClick={onClose} className="btn btn-secondary">Cancel</button>
            <button type="submit" className="btn btn-primary">{isEditing ? 'Update Vehicle' : 'Register Vehicle'}</button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default VehicleModal;
