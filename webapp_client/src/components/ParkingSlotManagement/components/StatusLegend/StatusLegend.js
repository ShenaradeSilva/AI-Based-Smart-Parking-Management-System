import React, { useState, useEffect } from 'react';
import API from '../../../../api/axios';
import './StatusLegend.css';

const StatusLegend = () => {
  const [statusCounts, setStatusCounts] = useState({
    available: 0,
    occupied: 0,
    reserved: 0,
    maintenance: 0,
  });

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchSlotStatuses = async () => {
      try {
        const res = await API.get('/api/parking/slots'); // Ensure this endpoint returns all slot data
        const slots = res.data || [];

        // Count statuses
        const counts = slots.reduce(
          (acc, slot) => {
            const status = slot.status?.toLowerCase() || 'available';
            if (acc.hasOwnProperty(status)) {
              acc[status] += 1;
            }
            return acc;
          },
          { available: 0, occupied: 0, reserved: 0, maintenance: 0 }
        );

        setStatusCounts(counts);
        setLoading(false);
      } catch (err) {
        console.error('Error fetching slot statuses:', err);
        setError('Failed to fetch slot statuses.');
        setLoading(false);
      }
    };

    fetchSlotStatuses();
  }, []);

  if (loading) {
    return <div className="status-legend">Loading slot statuses...</div>;
  }

  if (error) {
    return <div className="status-legend error">{error}</div>;
  }

  return (
    <div className="status-legend">
      {Object.entries(statusCounts).map(([status, count]) => (
        <div key={status} className="legend-item">
          <div className={`color-box ${status}`}></div>
          <span>
            {status.charAt(0).toUpperCase() + status.slice(1)} ({count})
          </span>
        </div>
      ))}
    </div>
  );
};

export default StatusLegend;
