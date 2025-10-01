import React from 'react';
import DashboardContent from '../DashboardContent/DashboardContent';
import NotificationsPanel from '../DashboardContent/NotificationsPanel';
import './MainContent.css';

const MainContent = ({ dashboardData, onViewDrivers, onViewOccupancyReport, navigate, notifications }) => {
  return (
    <>
      <DashboardContent 
        dashboardData={dashboardData}
        onViewDrivers={onViewDrivers}
        onViewOccupancyReport={onViewOccupancyReport}
        navigate={navigate}
      />
      
      <NotificationsPanel notifications={notifications} />
    </>
  );
};


export default MainContent;
