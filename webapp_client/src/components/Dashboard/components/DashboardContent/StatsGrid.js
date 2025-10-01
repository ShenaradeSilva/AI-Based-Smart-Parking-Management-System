import React from 'react';
import './StatsGrid.css';

const StatsGrid = ({ dashboardData, onViewDrivers, onViewOccupancyReport }) => {
  return (
    <>
      <div className="stat-card">
        <h3>Registered Vehicles</h3>
        <p className="stat-number">{dashboardData.registeredVehicles}</p>
        <button className="view-details-btn" onClick={onViewDrivers}>
          View Details
        </button>
      </div>

      <div className="stat-card">
        <h3>Real-Time Occupancy</h3>
        <p className="stat-number">{dashboardData.occupancyRate}%</p>
        <button className="view-report-btn" onClick={onViewOccupancyReport}>
          View Report
        </button>
      </div>

      <div className="stat-card">
        <h3>Uptime</h3>
        <p className={`status ${dashboardData.uptimeStatus.toLowerCase()}`}>
          {dashboardData.uptimeStatus}
        </p>
      </div>
    </>
  );
};

export default StatsGrid;