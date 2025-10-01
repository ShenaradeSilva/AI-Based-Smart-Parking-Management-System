import React from 'react';
import StatsGrid from './StatsGrid';
import SummaryGrid from './SummaryGrid';
import './DashboardContent.css';

const DashboardContent = ({ dashboardData, onViewDrivers, onViewOccupancyReport, navigate }) => {
  return (
    <div className="dashboard-content">
      <div className="stats-grid">
        <StatsGrid 
          dashboardData={dashboardData}
          onViewDrivers={onViewDrivers}
          onViewOccupancyReport={onViewOccupancyReport}
        />
      </div>
      
      <div className="summary-grid">
        <SummaryGrid dashboardData={dashboardData} navigate={navigate} />
      </div>
    </div>
  );
};

export default DashboardContent;