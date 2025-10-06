import React from 'react';
import './BookingModal.css';
import API from '../../../../api/axios'; // Axios instance

const BookingModal = ({ booking, onClose }) => {
  const handlePrintReceipt = async () => {
    if (!booking.id) return;

    try {
      // Call backend receipt endpoint
      const res = await API.get(`/api/reservations/${booking.id}/receipt`);
      const receiptData = res.data;

      // Open printable receipt window
      const receiptWindow = window.open('', '_blank');
      receiptWindow.document.write(`
        <html>
          <head>
            <title>Reservation Receipt</title>
            <style>
              body {
                font-family: Arial, sans-serif;
                margin: 40px;
                line-height: 1.6;
                color: #333;
              }
              h2 { text-align: center; color: #222; }
              table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
              }
              td {
                padding: 8px 10px;
                border-bottom: 1px solid #ddd;
              }
              .label {
                font-weight: bold;
                width: 40%;
                color: #555;
              }
              .value {
                width: 60%;
              }
            </style>
          </head>
          <body>
            <h2>Parking Reservation Receipt</h2>
            <table>
              <tr><td class="label">Reservation ID:</td><td class="value">${receiptData.reservation_id}</td></tr>
              <tr><td class="label">Booking Reference:</td><td class="value">${booking.bookingReference}</td></tr>
              <tr><td class="label">User ID:</td><td class="value">${receiptData.user_id || 'N/A'}</td></tr>
              <tr><td class="label">Location:</td><td class="value">${booking.location}</td></tr>
              <tr><td class="label">Slot:</td><td class="value">${booking.slot}</td></tr>
              <tr><td class="label">Date:</td><td class="value">${booking.date}</td></tr>
              <tr><td class="label">Time:</td><td class="value">${booking.time}</td></tr>
              <tr><td class="label">Duration:</td><td class="value">${booking.duration} hour(s)</td></tr>
              <tr><td class="label">Vehicle:</td><td class="value">${booking.vehicle}</td></tr>
              <tr><td class="label">Amount:</td><td class="value">LKR ${booking.amount}</td></tr>
              <tr><td class="label">Payment Method:</td><td class="value">${booking.paymentMethod}</td></tr>
              <tr><td class="label">Payment Status:</td><td class="value">${booking.paymentStatus}</td></tr>
              <tr><td class="label">Status:</td><td class="value">${booking.status}</td></tr>
            </table>
            <p style="text-align:center; margin-top:30px;">Thank you for using ParkFlow!</p>
          </body>
        </html>
      `);
      receiptWindow.document.close();
      receiptWindow.print();
    } catch (err) {
      console.error('Failed to fetch receipt:', err);
      alert('Failed to fetch receipt from backend.');
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h3>Booking Details</h3>
          <button className="close-btn" onClick={onClose}>×</button>
        </div>

        <div className="modal-body">
          <div className="detail-row"><span className="detail-label">Booking Reference:</span><span className="detail-value">{booking.bookingReference}</span></div>
          <div className="detail-row"><span className="detail-label">Status:</span><span className={`detail-value status ${booking.status.toLowerCase()}`}>{booking.status}</span></div>
          <div className="detail-row"><span className="detail-label">Location:</span><span className="detail-value">{booking.location}</span></div>
          <div className="detail-row"><span className="detail-label">Parking Slot:</span><span className="detail-value">{booking.slot}</span></div>
          <div className="detail-row"><span className="detail-label">Date:</span><span className="detail-value">{booking.date}</span></div>
          <div className="detail-row"><span className="detail-label">Time:</span><span className="detail-value">{booking.time}</span></div>
          <div className="detail-row"><span className="detail-label">Duration:</span><span className="detail-value">{booking.duration} hour(s)</span></div>
          <div className="detail-row"><span className="detail-label">Vehicle Number:</span><span className="detail-value">{booking.vehicle}</span></div>
          <div className="detail-row"><span className="detail-label">Amount:</span><span className="detail-value amount">LKR {booking.amount}</span></div>
          <div className="detail-row"><span className="detail-label">Payment Method:</span><span className="detail-value">{booking.paymentMethod}</span></div>
          <div className="detail-row"><span className="detail-label">Payment Status:</span><span className={`detail-value payment-status ${booking.paymentStatus.toLowerCase()}`}>{booking.paymentStatus}</span></div>
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
