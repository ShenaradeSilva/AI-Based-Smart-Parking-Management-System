import React, { useState, useEffect } from 'react';
import API from '../../../../api/axios';
import './Modals.css';

const AddLocationModal = ({ onClose, onAddLocation, currentAdmin }) => {
  const [newLocation, setNewLocation] = useState({
    name: '',
    address: '',
    totalLots: 1,
    ratePerHour: 0,
  });

  const [lotSlots, setLotSlots] = useState([{ lotName: '', slots: 0 }]);

  // Update lotSlots when totalLots changes
  useEffect(() => {
    const totalLots = Number(newLocation.totalLots) || 1;
    const newLotSlots = [];
    for (let i = 0; i < totalLots; i++) {
      newLotSlots.push(lotSlots[i] || { lotName: '', slots: 0 });
    }
    setLotSlots(newLotSlots);
  }, [newLocation.totalLots]);

  const handleLotChange = (index, field, value) => {
    const updated = [...lotSlots];
    updated[index][field] = field === 'slots' ? Number(value) || 0 : value;
    setLotSlots(updated);
  };

  const handleSubmit = async () => {
    // Validation
    if (!newLocation.name?.trim() || !newLocation.address?.trim() || newLocation.totalLots <= 0 || newLocation.ratePerHour <= 0) {
      alert('Please fill all fields and ensure lots and rate are greater than 0.');
      return;
    }

    for (let i = 0; i < lotSlots.length; i++) {
      if (!lotSlots[i].lotName?.trim()) {
        alert(`Please enter a name for Lot ${i + 1}`);
        return;
      }
      if (lotSlots[i].slots <= 0) {
        alert(`Please enter slots for ${lotSlots[i].lotName} (must be > 0)`);
        return;
      }
    }

    if (!currentAdmin?.id) {
      alert('Admin information missing. Please re-login.');
      return;
    }

    const payload = {
      name: newLocation.name.trim(),
      address: newLocation.address.trim(),
      total_lots: Number(newLocation.totalLots),
      rate_per_hour: Number(newLocation.ratePerHour),
      lots: lotSlots.map(l => ({ name: l.lotName.trim(), slots: l.slots }))
    };

    try {
      const res = await API.post(`/parking/locations?admin_id=${currentAdmin.id}`, payload);

      if (res.data?.id) {
        onAddLocation({
          id: res.data.id,
          name: payload.name,
          address: payload.address,
          totalLots: payload.total_lots,
          ratePerHour: payload.rate_per_hour,
          lots: payload.lots
        });
      }
    } catch (err) {
      console.error('Error adding location:', err);
      alert(err.response?.data?.detail || 'Failed to add location.');
    }

    setNewLocation({ name: '', address: '', totalLots: 1, ratePerHour: 0 });
    setLotSlots([{ lotName: '', slots: 0 }]);
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
            />
          </div>
          <div className="form-group">
            <label>Address</label>
            <input
              type="text"
              value={newLocation.address}
              onChange={(e) => setNewLocation({ ...newLocation, address: e.target.value })}
              placeholder="Enter address"
            />
          </div>
          <div className="form-group">
            <label>Number of Parking Lots</label>
            <input
              type="number"
              min="1"
              value={newLocation.totalLots}
              onChange={(e) => setNewLocation({ ...newLocation, totalLots: Number(e.target.value) || 1 })}
            />
          </div>
          <div className="form-group">
            <label>Rate per Hour (LKR)</label>
            <input
              type="number"
              min="1"
              value={newLocation.ratePerHour}
              onChange={(e) => setNewLocation({ ...newLocation, ratePerHour: Number(e.target.value) || 0 })}
            />
          </div>

          {/* Lot slot inputs */}
          <div className="lot-slots-section">
            <h4>Slots per Lot</h4>
            {lotSlots.map((lot, index) => (
              <div key={index} className="form-group lot-slot-row">
                <input
                  type="text"
                  value={lot.lotName}
                  onChange={(e) => handleLotChange(index, 'lotName', e.target.value)}
                  placeholder={`Enter name for Lot ${index + 1}`}
                />
                <input
                  type="number"
                  min="1"
                  value={lot.slots}
                  onChange={(e) => handleLotChange(index, 'slots', e.target.value)}
                  placeholder="Enter number of slots"
                />
              </div>
            ))}
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
