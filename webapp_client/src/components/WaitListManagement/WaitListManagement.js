import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import API from '../../api/axios'; // Reuse your configured Axios instance
import './WaitListManagement.css';
import WaitListStats from './components/WaitListStats/WaitListStats';
import WaitListTable from './components/WaitListTable/WaitListTable';
import HeaderPages from '../Common/HeaderPages';

const WaitListManagement = () => {
  const navigate = useNavigate();
  const [waitlistQueue, setWaitlistQueue] = useState([]);
  const [loading, setLoading] = useState(true);

  // Fetch waitlist queue from backend
  const fetchWaitlist = async () => {
    try {
      const response = await API.get('/api/waitlist/get');
      const mappedQueue = response.data.map(item => ({
        id: item.waitlist_id,
        driverName: item.user_name,
        vehicleNumber: item.vehicle_number,
        parkingSlot: item.parking_slot_number,
        bookingDate: item.requested_at?.split('T')[0] || null,
        requestedTime: item.requested_at?.split('T')[1]?.slice(0, 5) || null,
        status: item.status,
        priority: item.priority,
        notified_at: item.notified_at,
        createdAt: item.requested_at,
      }));
      setWaitlistQueue(mappedQueue);
    } catch (error) {
      console.error('Failed to fetch waitlist:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchWaitlist();
  }, []);

  const handleBackToDashboard = () => navigate('/dashboard');

  const handleNotify = async (id) => {
    try {
      const response = await API.post(`/api/waitlist/notify/${id}`);  
      const updatedEntry = {
        id: response.data.waitlist_id,
        status: response.data.status,
        notified_at: response.data.notified_at,
      };
      setWaitlistQueue(prev =>
        prev.map(item =>
          item.id === id ? { ...item, ...updatedEntry } : item
        )
      );
    } catch (error) {
      console.error('Failed to notify driver:', error);
    }
  };

  const handleRemove = async (id) => {
    try {
      await API.delete(`/api/waitlist/${id}/remove`); 
      setWaitlistQueue(prev => prev.filter(item => item.id !== id));
    } catch (error) {
      console.error('Failed to remove waitlist request:', error);
      setWaitlistQueue(prev => prev.filter(item => item.id !== id));
    }
  };

  // Dynamic stats
  const today = new Date().toISOString().slice(0, 10);
  const activeWaitlist = waitlistQueue.filter(
    item => item.status === 'pending' || item.status === 'notified'
  ).length;

  const notifiedToday = waitlistQueue.filter(
    item => item.status === 'notified' && item.notified_at?.slice(0, 10) === today
  ).length;

  const convertedCount = waitlistQueue.filter(
    item => item.status === 'converted' || item.status === 'booked'
  ).length;

  const conversionRate =
    waitlistQueue.length > 0 ? Math.round((convertedCount / waitlistQueue.length) * 100) : 0;

  if (loading) return <p>Loading waitlist...</p>;

  return (
    <div className="waitlist-management">
      <HeaderPages title="Wait List Requests" onBack={handleBackToDashboard} />
      <WaitListStats waitlistQueue={waitlistQueue} />
      <WaitListTable
        waitlistQueue={waitlistQueue}
        onNotify={handleNotify}
        onRemove={handleRemove}
      />
    </div>
  );
};

export default WaitListManagement;
