import React from 'react';
import './BookingCard.css';

const BookingCard = ({ booking, onViewDetails, onCancel }) => {
  return (
    <div className="booking-card">
      <div className="booking-header">
        <h3>{booking.location}</h3>
        <span className={`status-badge ${booking.status.toLowerCase()}`}>{booking.status}</span>
      </div>
      <div className="booking-details">
        <div className="detail">
          <span className="label">Date:</span>
          <span className="value">{booking.date}</span>
        </div>
        <div className="detail">
          <span className="label">Time:</span>
          <span className="value">{booking.time}</span>
        </div>
        <div className="detail">
          <span className="label">Slot:</span>
          <span className="value">{booking.slot}</span>
        </div>
        <div className="detail">
          <span className="label">Amount:</span>
          <span className="value">{booking.amount}</span>
        </div>
      </div>
      <div className="booking-actions">
        <button className="action-btn view-btn" onClick={() => onViewDetails(booking)}>
          View Details
        </button>
        {booking.status === 'Upcoming' && (
          <button className="action-btn cancel-btn" onClick={() => onCancel(booking.id)}>
            Cancel Booking
          </button>
        )}
      </div>
    </div>
  );
};

export default BookingCard;