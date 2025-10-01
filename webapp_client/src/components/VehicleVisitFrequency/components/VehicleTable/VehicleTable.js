import React from 'react';
import './VehicleTable.css';
import analyticsData from '../../../../data/analyticsData'; 

const VehicleTable = ({ data }) => {
  // Use mock data if no data is provided
  const tableData = data && data.length > 0
    ? data
    : analyticsData.vehicleVisitFrequency.vehicles;

  if (!tableData || tableData.length === 0) {
    return <p className="no-data-message">No vehicle data available.</p>;
  }

  return (
    <table className="vehicle-table">
      <thead>
        <tr>
          <th>Vehicle</th>
          <th>Total Visits</th>
          <th>Preferred Slot</th>
          <th>Avg Duration</th>
        </tr>
      </thead>
      <tbody>
        {tableData.map((vehicle, index) => (
          <tr key={index}>
            <td>{vehicle.vehicle}</td>
            <td>{vehicle.totalVisits}</td>
            <td>{vehicle.preferredSlot}</td>
            <td>{vehicle.avgDuration}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default VehicleTable;
