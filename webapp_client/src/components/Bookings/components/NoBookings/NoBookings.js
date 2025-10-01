import React from 'react';
import './NoBookings.css';

const NoBookings = () => {
  return (
    <div className="no-bookings">
      <p>No bookings match your filters.</p>
      <button className="reset-filters-btn" onClick={() => window.location.reload()}>
        Reset Filters
      </button>
    </div>
  );
};

export default NoBookings;