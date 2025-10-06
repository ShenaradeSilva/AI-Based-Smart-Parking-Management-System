import React, { useState, useEffect } from 'react';
import './CreateBookingModal.css';
import { CloseIcon } from '../../../Icons/Icons';
import API from '../../../../api/axios';
import { useNavigate } from 'react-router-dom';

const HOURLY_RATE = 150;

const CreateBookingModal = ({ vehicles, locations, bookedSlots, onClose, onSave }) => {
  const navigate = useNavigate();

  const [formData, setFormData] = useState({
    date: '',
    time: '',
    location: locations[0] || '',
    slot: '',
    vehicle: '',
    duration: '',
    amount: 0,
    paymentMethod: 'Cash',
    status: 'Upcoming',
    bookingReference: `REF${Math.floor(Math.random() * 10000) + 1000}`,
    paymentStatus: 'Pending',
  });

  const [availableSlots, setAvailableSlots] = useState([]);
  const [saving, setSaving] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [vehicleOptions, setVehicleOptions] = useState([]);

  // Prepare vehicle options
  useEffect(() => {
    setVehicleOptions([...vehicles.map(v => v.plate_number || v.plateNumber), 'Register Vehicle']);
  }, [vehicles]);

  // Update available slots when location changes
  useEffect(() => {
    if (!formData.location) return;

    const allSlots = Array.from({ length: 20 }, (_, i) => `Slot ${i + 1}`);
    const booked = bookedSlots[formData.location] || [];
    const freeSlots = allSlots.filter(s => !booked.includes(s));

    setAvailableSlots(freeSlots);
    setFormData(prev => ({ ...prev, slot: freeSlots[0] || '' }));
  }, [formData.location, bookedSlots]);

  // Update amount when duration changes
  useEffect(() => {
    const durationNum = Number(formData.duration);
    setFormData(prev => ({ ...prev, amount: !isNaN(durationNum) ? durationNum * HOURLY_RATE : 0 }));
  }, [formData.duration]);

  const handleChange = (e) => {
    const { name, value } = e.target;

    if (name === 'vehicle' && value === 'Register Vehicle') {
      onClose();
      navigate('vehicle-management'); // relative navigation
      return;
    }

    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async () => {
    setErrorMsg('');

    if (!formData.date || !formData.time || !formData.location || !formData.slot || !formData.duration || !formData.vehicle) {
      setErrorMsg('Please fill all required fields.');
      return;
    }

    setSaving(true);

    try {
      const vehicleId = vehicles.find(v => (v.plate_number || v.plateNumber) === formData.vehicle)?.id;
      if (!vehicleId) {
        setErrorMsg('Selected vehicle must be registered.');
        setSaving(false);
        return;
      }

      const parkingSlotId = formData.slot.replace('Slot ', '');

      const response = await API.post('/api/reservations/create', {
        date: formData.date,
        start_time: formData.time,
        end_time: formData.time, // adjust if needed
        parking_slot_id: parkingSlotId,
        vehicle_id: vehicleId,
        status: formData.status,
        duration: Number(formData.duration),
        amount: formData.amount,
        payment_method: formData.paymentMethod,
      });

      const savedReservation = response.data;

      onSave({
        id: savedReservation.reservation_id,
        location: formData.location,
        slot: formData.slot,
        date: savedReservation.date,
        time: savedReservation.start_time,
        duration: savedReservation.duration || Number(formData.duration),
        status: savedReservation.status,
        vehicle: formData.vehicle,
        amount: savedReservation.amount || formData.amount,
        paymentMethod: savedReservation.payment_method || formData.paymentMethod,
        paymentStatus: savedReservation.payment_status || 'Pending',
        bookingReference: `REF${savedReservation.reservation_id}`,
      });

      onClose();
    } catch (err) {
      setErrorMsg(err.response?.data?.detail || 'An unexpected error occurred while creating the booking.');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content create-booking-modal">
        <div className="modal-header">
          <h3>Create New Booking</h3>
          <button className="close-btn" onClick={onClose}><CloseIcon /></button>
        </div>

        <div className="modal-body">
          {errorMsg && <p className="error-message">{errorMsg}</p>}

          <label>Date:</label>
          <input type="date" name="date" value={formData.date} onChange={handleChange} />

          <label>Time:</label>
          <input type="time" name="time" value={formData.time} onChange={handleChange} />

          <label>Location:</label>
          <select name="location" value={formData.location} onChange={handleChange}>
            {locations.map(loc => <option key={loc} value={loc}>{loc}</option>)}
          </select>

          <label>Parking Slot:</label>
          <select name="slot" value={formData.slot} onChange={handleChange}>
            {availableSlots.length > 0
              ? availableSlots.map(s => <option key={s} value={s}>{s}</option>)
              : <option value="">No slots available</option>}
          </select>

          <label>Vehicle:</label>
          <input
            list="vehicle-list"
            name="vehicle"
            value={formData.vehicle}
            onChange={handleChange}
            placeholder="Select or type vehicle"
          />
          <datalist id="vehicle-list">
            {vehicleOptions.map(v => <option key={v} value={v} />)}
          </datalist>

          <label>Duration (hours):</label>
          <input type="number" name="duration" min="1" value={formData.duration} onChange={handleChange} />

          <label>Amount (LKR):</label>
          <input type="number" name="amount" value={formData.amount} readOnly />

          <label>Payment Method:</label>
          <input type="text" name="paymentMethod" value="Cash" disabled />
        </div>

        <div className="modal-footer">
          <button className="btn btn-secondary" onClick={onClose} disabled={saving}>Cancel</button>
          <button className="btn btn-primary" onClick={handleSubmit} disabled={saving}>
            {saving ? 'Saving...' : 'Create Booking'}
          </button>
        </div>
      </div>
    </div>
  );
};

export default CreateBookingModal;
