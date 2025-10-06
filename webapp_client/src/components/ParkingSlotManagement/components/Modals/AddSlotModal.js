import React, { useState, useEffect } from 'react';
import './Modals.css';
import API from '../../../../api/axios';

const AddSlotModal = ({ editingSlot, locations, onClose, onAddSlot, adminId }) => {
  const [slotData, setSlotData] = useState({
    id: '',            // backend ID
    slotNumber: '',    // display slot number
    location: '',
    status: 'Available',
    slotType: 'vehicle' // NEW: default to vehicle
  });

  useEffect(() => {
    if (editingSlot) {
      setSlotData({
        id: editingSlot.id,
        slotNumber: editingSlot.slotNumber,
        location: editingSlot.location,
        status: editingSlot.status || 'Available',
        slotType: editingSlot.slotType || 'vehicle'
      });
    } else {
      setSlotData({
        id: '',
        slotNumber: '',
        location: '',
        status: 'Available',
        slotType: 'vehicle'
      });
    }
  }, [editingSlot]);

  const handleSubmit = async () => {
    if (!slotData.slotNumber || !slotData.location) {
      alert('Please fill all fields.');
      return;
    }

    const selectedLocation = locations.find(loc => loc.name === slotData.location);
    const locationId = selectedLocation ? (selectedLocation.location_id || selectedLocation.id) : null;
    if (!locationId) {
      alert('Selected location is invalid.');
      return;
    }

    // Normalize inputs
    const status = slotData.status ? slotData.status.toLowerCase() : 'available';
    const slotType = slotData.slotType ? slotData.slotType.toLowerCase() : 'vehicle';
    const timestamp = new Date().toISOString().slice(0, 16).replace('T', ' ');

    const payload = {
      slot_number: slotData.slotNumber,
      parking_lot_id: locationId,
      slot_type: slotType,
      status
    };

    try {
      if (slotData.id) {
        // Edit existing slot
        await API.put(`/parking/slots/${slotData.id}`, payload);
        onAddSlot({ ...slotData, status, slotType, lastUpdated: timestamp });
      } else {
        // Add new slot
        const res = await API.post(`/parking/slots?admin_id=${adminId}`, payload);
        onAddSlot({
          ...slotData,
          id: res.data?.id ?? Date.now(),
          status,
          slotType,
          lastUpdated: timestamp
        });
      }
    } catch (err) {
      console.error('Error saving slot', err);
      alert('Failed to save slot on backend. Using mock data.');
      // fallback mock update
      onAddSlot({
        ...slotData,
        id: slotData.id || Date.now(),
        status,
        slotType,
        lastUpdated: timestamp
      });
    }

    onClose();
  };

  return (
    <div className="modal-overlay">
      <div className="modal">
        <div className="modal-header">
          <h3>{slotData.id ? 'Edit Slot' : 'Add Slot'}</h3>
          <button className="close-button" onClick={onClose}>×</button>
        </div>

        <div className="modal-content">
          <div className="form-group">
            <label>Slot ID</label>
            <input
              type="text"
              value={slotData.slotNumber}
              onChange={(e) => setSlotData({ ...slotData, slotNumber: e.target.value })}
              placeholder="Enter slot ID (e.g., A-01)"
            />
          </div>

          <div className="form-group">
            <label>Location</label>
            <select
              value={slotData.location}
              onChange={(e) => setSlotData({ ...slotData, location: e.target.value })}
            >
              <option value="">Select Location</option>
              {locations.map(loc => (
                <option key={loc.location_id || loc.id} value={loc.name}>
                  {loc.name}
                </option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label>Slot Type</label>
            <select
              value={slotData.slotType}
              onChange={(e) => setSlotData({ ...slotData, slotType: e.target.value })}
            >
              <option value="vehicle">Vehicle (Square)</option>
              <option value="bike">Bike (Rectangle)</option>
            </select>
          </div>

          <div className="form-group">
            <label>Status</label>
            <select
              value={slotData.status}
              onChange={(e) => setSlotData({ ...slotData, status: e.target.value })}
            >
              <option value="Available">Available</option>
              <option value="Occupied">Occupied</option>
              <option value="Reserved">Reserved</option>
              <option value="Maintenance">Maintenance</option>
            </select>
          </div>

          <div className="modal-actions">
            <button className="cancel-button" onClick={onClose}>Cancel</button>
            <button className="confirm-button" onClick={handleSubmit}>
              {slotData.id ? 'Update Slot' : 'Add Slot'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AddSlotModal;
