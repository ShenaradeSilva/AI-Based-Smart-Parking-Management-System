import React, { useState, useEffect } from 'react';
import API from '../../../../api/axios';
import './StatusLegend.css';

// Mock fallback
const mockStatusCounts = { available: 10, occupied: 5, reserved: 2, maintenance: 1 };

const StatusLegend = () => {
  const [statusCounts, setStatusCounts] = useState(mockStatusCounts);

  useEffect(() => {
    const fetchSlotStatuses = async () => {
      try {
        const res = await API.get('/api/parking/slots'); // Full backend endpoint
        const slots = res.data;

        const counts = slots.reduce(
          (acc, slot) => {
            const status = slot.status?.toLowerCase() || 'available';
            if (acc[status] !== undefined) acc[status] += 1;
            return acc;
          },
          { available: 0, occupied: 0, reserved: 0, maintenance: 0 }
        );

        setStatusCounts(counts);
      } catch (err) {
        console.warn('Failed to fetch from backend, using mock data', err);
        setStatusCounts(mockStatusCounts);
      }
    };

    fetchSlotStatuses();
  }, []);

  return (
    <div className="status-legend">
      {Object.entries(statusCounts).map(([status, count]) => (
        <div key={status} className="legend-item">
          <div className={`color-box ${status}`}></div>
          <span>{status.charAt(0).toUpperCase() + status.slice(1)} ({count})</span>
        </div>
      ))}
    </div>
  );
};

export default StatusLegend;
