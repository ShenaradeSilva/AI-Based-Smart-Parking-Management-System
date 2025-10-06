import React, { useState } from 'react';
import API from '../../../../api/axios';
import './Modals.css';

const AddLocationModal = ({ onClose, onAddLocation, currentAdmin }) => {
  const [newLocation, setNewLocation] = useState({
    name: '',
    address: '',
    totalSlots: 0,
    ratePerHour: 0, // <-- new field
  });

  const handleSubmit = async () => {
    if (
      !newLocation.name?.trim() ||
      !newLocation.address?.trim() ||
      newLocation.totalSlots <= 0 ||
      newLocation.ratePerHour <= 0
    ) {
      alert('Please fill all fields and ensure total slots and rate per hour are greater than 0.');
      return;
    }

    if (!currentAdmin?.id) {
      alert('Admin information missing. Please re-login.');
      return;
    }

    const payload = {
      name: newLocation.name.trim(),
      address: newLocation.address.trim(),
      total_slots: Number(newLocation.totalSlots),
      rate_per_hour: Number(newLocation.ratePerHour), // <-- included in payload
    };

    try {
      const res = await API.post(`/parking/locations?admin_id=${currentAdmin.id}`, payload);
      
      if (res.data?.id) {
        if (typeof onAddLocation === 'function') {
          onAddLocation({
            id: res.data.id,
            name: payload.name,
            address: payload.address,
            totalSlots: payload.total_slots,
            ratePerHour: payload.rate_per_hour, // <-- updated here
          });
        }
      }
    } catch (err) {
      console.error('Error adding location to backend:', err);
      alert(err.response?.data?.detail || 'Failed to add location to backend.');
    }

    setNewLocation({ name: '', address: '', totalSlots: 0, ratePerHour: 0 });
    onClose();
  };

  return (
    <div className="modal-overlay">
      <div className="modal">
        <div className="modal-header">
          <h3>Add New Location</h3>
          <button className="close-button" onClick={onClose}>×</button>
        </div>
        <div className="modal-content">
          <div className="form-group">
            <label>Location Name</label>
            <input
              type="text"
              value={newLocation.name}
              onChange={(e) => setNewLocation({ ...newLocation, name: e.target.value })}
              placeholder="Enter location name"
              required
            />
          </div>
          <div className="form-group">
            <label>Address</label>
            <input
              type="text"
              value={newLocation.address}
              onChange={(e) => setNewLocation({ ...newLocation, address: e.target.value })}
              placeholder="Enter address"
              required
            />
          </div>
          <div className="form-group">
            <label>Total Slots</label>
            <input
              type="number"
              min="1"
              value={newLocation.totalSlots}
              onChange={(e) =>
                setNewLocation({ ...newLocation, totalSlots: Number(e.target.value) || 0 })
              }
              placeholder="Enter total slots"
              required
            />
          </div>
          <div className="form-group">
            <label>Rate per Hour (LKR)</label>
            <input
              type="number"
              min="1"
              value={newLocation.ratePerHour}
              onChange={(e) =>
                setNewLocation({ ...newLocation, ratePerHour: Number(e.target.value) || 0 })
              }
              placeholder="Enter rate per hour"
              required
            />
          </div>
          <div className="modal-actions">
            <button className="cancel-button" onClick={onClose}>Cancel</button>
            <button className="confirm-button" onClick={handleSubmit}>Add Location</button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AddLocationModal;
