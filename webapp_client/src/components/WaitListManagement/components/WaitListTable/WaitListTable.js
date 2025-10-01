import React from 'react';
import NoWaitList from '../NoWaitList/NoWaitList';
import './WaitListTable.css';
import { DeleteIcon, NotifyIcon } from '../../../Icons/Icons';

const WaitListTable = ({ waitlistQueue, onNotify, onRemove }) => {
  if (!waitlistQueue || waitlistQueue.length === 0) {
    return <NoWaitList message="No drivers in the waitlist" />;
  }

  const getWaitDuration = (createdAt) => {
    if (!createdAt) return '-';
    const now = new Date();
    const requestTime = new Date(createdAt);
    const diffMs = now - requestTime;
    const diffMins = Math.floor(diffMs / 60000);
    const hours = Math.floor(diffMins / 60);
    const mins = diffMins % 60;
    return hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;
  };

  const formatDate = (timestamp) => (timestamp ? new Date(timestamp).toLocaleDateString() : '-');
  const formatTime = (timestamp) =>
    timestamp ? new Date(timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '-';
  const formatStatus = (status) => (status ? status.charAt(0).toUpperCase() + status.slice(1) : '-');

  return (
    <div className="waitlist-queue">
      <h2>Current Waitlist Queue</h2>
      <table className="waitlist-table">
        <thead>
          <tr>
            <th>Request ID</th>
            <th>Driver Name</th>
            <th>Vehicle Number</th>
            <th>Parking Slot</th>
            <th>Date</th>
            <th>Requested Time</th>
            <th>Wait Duration</th>
            <th>Status</th>
            <th>Priority</th>
            <th className="actions">Actions</th> {/* updated */}
          </tr>
        </thead>
        <tbody>
          {waitlistQueue.map((item) => (
            <tr key={item.id}>
              <td>{item.id || '-'}</td>
              <td>{item.driverName || '-'}</td>
              <td>{item.vehicleNumber || '-'}</td>
              <td>{item.parkingSlot || '-'}</td>
              <td>{formatDate(item.bookingDate)}</td>
              <td>{item.requestedTime || '-'}</td>
              <td>{getWaitDuration(item.createdAt)}</td>
              <td className="status-cell">
                <span className={`status ${item.status || ''}`}>{formatStatus(item.status)}</span>
              </td>
              <td className="priority-cell">
                <span className={`priority-badge ${item.priority?.toLowerCase() || ''}`}>
                  {item.priority || '-'}
                </span>
              </td>
              <td className="actions-cell"> {/* updated */}
                <div className="action-buttons">
                  <button
                    className="btn-notify"
                    onClick={() => onNotify(item.id)}
                    disabled={item.status === 'notified' || item.status === 'converted'}
                  >
                    <NotifyIcon /> Notify Available
                  </button>
                  <button
                    className="btn-remove"
                    onClick={() => onRemove(item.id)}
                  >
                    <DeleteIcon /> Remove
                  </button>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default WaitListTable;
