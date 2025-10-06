import React from 'react';
import './StatsSection.css';

const StatsSection = ({ stats }) => {
  return (
    <div className="cancellation-stats">
      <h2>Cancellation Statistics</h2>
      <div className="stats-cards">
        <div className="stat-card">
          <div className="stat-number">{stats.todayRequests}</div>
          <div className="stat-label">Today's Requests</div>
        </div>
        <div className="stat-card">
          <div className="stat-number">{stats.approvalRate}%</div>
          <div className="stat-label">Approval Rate</div>
        </div>
      </div>
    </div>
  );
};

export default StatsSection;
