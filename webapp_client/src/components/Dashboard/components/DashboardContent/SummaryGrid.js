import React from 'react';
import './SummaryGrid.css';

const SummaryGrid = ({ dashboardData, navigate, isMockData = false }) => {
  const renderItem = (title, value, path) => (
    <div
      className="summary-item"
      onClick={() => path && navigate(path)}
      style={{ cursor: path ? 'pointer' : 'default', position: 'relative' }}
    >
      <h4>{title}</h4>
      <p>{value}</p>
      {isMockData && (
        <span className="mock-badge">mock</span>
      )}
    </div>
  );

  return (
    <>
      {renderItem('Bookings', dashboardData.bookings, '/dashboard/bookings')}
      {renderItem('Occupied Slots', dashboardData.occupiedSlots, '/dashboard/manage-parking')}
      {renderItem('Available Slots', dashboardData.availableSlots, '/dashboard/manage-parking')}
      {renderItem('Alerts', dashboardData.alerts, '/dashboard/notifications')}
    </>
  );
};

export default SummaryGrid;
