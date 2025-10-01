import React from 'react';
import './BookingModal.css';
import API from '../../../../api/axios'; // your Axios instance

const BookingModal = ({ booking, onClose }) => {

  const handlePrintReceipt = async () => {
    if (!booking.id) return;

    try {
      // Call backend receipt endpoint
      const res = await API.get(`/api/reservations/${booking.id}/receipt`);
      const receiptData = res.data;

      // You can open a new window to print the receipt
      const receiptWindow = window.open('', '_blank');
      receiptWindow.document.write('<h3>Reservation Receipt</h3>');
      receiptWindow.document.write('<pre>' + JSON.stringify(receiptData, null, 2) + '</pre>');
      receiptWindow.document.close();
      receiptWindow.print();
    } catch (err) {
      console.error('Failed to fetch receipt:', err);
      alert('Failed to fetch receipt from backend.');
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={e => e.stopPropagation()}>
        <div className="modal-header">
          <h3>Booking Details</h3>
          <button className="close-btn" onClick={onClose}>×</button>
        </div>
        <div className="modal-body">
          <div className="detail-row">
            <span className="detail-label">Booking Reference:</span>
            <span className="detail-value">{booking.bookingReference}</span>
          </div>
          <div className="detail-row">
            <span className="detail-label">Status:</span>
            <span className={`detail-value status ${booking.status.toLowerCase()}`}>
              {booking.status}
            </span>
          </div>
          <div className="detail-row">
            <span className="detail-label">Location:</span>
            <span className="detail-value">{booking.location}</span>
          </div>
          <div className="detail-row">
            <span className="detail-label">Parking Slot:</span>
            <span className="detail-value">{booking.slot}</span>
          </div>
          <div className="detail-row">
            <span className="detail-label">Date:</span>
            <span className="detail-value">{booking.date}</span>
          </div>
          <div className="detail-row">
            <span className="detail-label">Time:</span>
            <span className="detail-value">{booking.time}</span>
          </div>
          <div className="detail-row">
            <span className="detail-label">Duration:</span>
            <span className="detail-value">{booking.duration}</span>
          </div>
          <div className="detail-row">
            <span className="detail-label">Vehicle Number:</span>
            <span className="detail-value">{booking.vehicle}</span>
          </div>
          <div className="detail-row">
            <span className="detail-label">Amount:</span>
            <span className="detail-value amount">{booking.amount}</span>
          </div>
          <div className="detail-row">
            <span className="detail-label">Payment Method:</span>
            <span className="detail-value">{booking.paymentMethod}</span>
          </div>
          <div className="detail-row">
            <span className="detail-label">Payment Status:</span>
            <span className={`detail-value payment-status ${booking.paymentStatus.toLowerCase()}`}>
              {booking.paymentStatus}
            </span>
          </div>
        </div>
        <div className="modal-footer">
          <button className="action-btn print-btn" onClick={handlePrintReceipt}>
            Print Receipt
          </button>
          <button className="action-btn close-modal-btn" onClick={onClose}>
            Close
          </button>
        </div>
      </div>
    </div>
  );
};

export default BookingModal;
