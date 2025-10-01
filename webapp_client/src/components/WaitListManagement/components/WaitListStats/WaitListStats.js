import React from 'react';
import './WaitListStats.css';

const WaitListStats = ({ waitlistQueue }) => {
  if (!waitlistQueue) return null;

  const today = new Date().toISOString().slice(0, 10);

  // Active waitlist: pending or notified
  const activeWaitlist = waitlistQueue.filter(
    item => item.status === 'pending' || item.status === 'notified'
  ).length;

  // Notified today
  const notifiedToday = waitlistQueue.filter(
    item => item.status === 'notified' && item.notified_at?.slice(0, 10) === today
  ).length;

  // Converted / booked
  const convertedCount = waitlistQueue.filter(
    item => item.status === 'converted' || item.status === 'booked'
  ).length;

  // Conversion rate
  const conversionRate =
    waitlistQueue.length > 0 ? Math.round((convertedCount / waitlistQueue.length) * 100) : 0;

  return (
    <div className="waitlist-stats">
      <div className="stat-card">
        <h3>{activeWaitlist}</h3>
        <p>Active Waitlist</p>
      </div>
      <div className="stat-card">
        <h3>{notifiedToday}</h3>
        <p>Notified Today</p>
      </div>
      <div className="stat-card">
        <h3>{convertedCount}</h3>
        <p>Converted to Bookings</p>
      </div>
      <div className="stat-card">
        <h3>{conversionRate}%</h3>
        <p>Conversion Rate</p>
      </div>
    </div>
  );
};

export default WaitListStats;
