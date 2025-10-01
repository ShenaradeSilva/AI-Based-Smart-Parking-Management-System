import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from '../../api/axios'; // Axios instance configured with baseURL
import './WaitListManagement.css';
import WaitListStats from './components/WaitListStats/WaitListStats';
import WaitListTable from './components/WaitListTable/WaitListTable';
import HeaderPages from '../Common/HeaderPages';
import { waitlistData as mockStats, waitlistQueue as mockQueue } from '../../data/waitList';

const WaitListManagement = () => {
  const navigate = useNavigate();
  const [waitlistQueue, setWaitlistQueue] = useState([]);
  const [loading, setLoading] = useState(true);

  // Fetch waitlist queue from backend
  const fetchWaitlist = async () => {
    try {
      const response = await axios.get('/waitlist'); // GET /waitlist returns all requests
      setWaitlistQueue(response.data || mockQueue);
    } catch (error) {
      console.error('Failed to fetch waitlist, using mock data.', error);
      setWaitlistQueue(mockQueue);
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
      await axios.post(`/waitlist/${id}/notify`); // backend endpoint
      setWaitlistQueue(prev =>
        prev.map(item =>
          item.id === id ? { ...item, status: 'notified', notified_at: new Date().toISOString() } : item
        )
      );
    } catch (error) {
      console.error('Failed to notify driver:', error);
    }
  };

  const handleRemove = async (id) => {
    try {
      // Call backend to delete the waitlist request
      await axios.delete(`/waitlist/${id}`);

      // Update the UI after successful deletion
      setWaitlistQueue(prev => prev.filter(item => item.id !== id));
    } catch (error) {
      console.error('Failed to remove waitlist request:', error);
      // Optionally fallback to remove from UI
      setWaitlistQueue(prev => prev.filter(item => item.id !== id));
    }
  };

  // Calculate dynamic stats
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
