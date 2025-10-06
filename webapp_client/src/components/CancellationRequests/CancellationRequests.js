import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import API from '../../api/axios';
import './CancellationRequests.css';
import RequestsTable from './components/RequestsTable/RequestsTable';
import StatsSection from './components/StatsSection/StatsSection';
import NoRequests from './components/NoRequests/NoRequests';
import HeaderPages from '../Common/HeaderPages';

const CancellationRequests = () => {
  const navigate = useNavigate();
  const [pendingRequests, setPendingRequests] = useState([]);
  const [stats, setStats] = useState({ todayRequests: 0, approvalRate: 0 });
  const [loading, setLoading] = useState(true);

  const fetchPendingRequests = async () => {
    try {
      const res = await API.get('/api/cancellations/list-pending');
      setPendingRequests(res.data);
    } catch (error) {
      console.error('Failed to fetch pending requests', error);
    }
  };

  const fetchStats = async () => {
    try {
      const res = await API.get('/api/cancellations/stats');
      setStats(res.data);
    } catch (error) {
      console.error('Failed to fetch stats', error);
    }
  };

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      await Promise.all([fetchPendingRequests(), fetchStats()]);
      setLoading(false);
    };
    fetchData();
  }, []);

  const handleApprove = async (requestId) => {
    try {
      await API.post(`/api/cancellations/${requestId}/approve`);
      setPendingRequests(prev => prev.filter(r => r.id !== requestId));
      setStats(prev => ({ ...prev, todayRequests: prev.todayRequests - 1 }));
    } catch (error) {
      console.error('Failed to approve request', error);
    }
  };

  const handleReject = async (requestId) => {
    try {
      await API.post(`/api/cancellations/${requestId}/reject`);
      setPendingRequests(prev => prev.filter(r => r.id !== requestId));
      setStats(prev => ({ ...prev, todayRequests: prev.todayRequests - 1 }));
    } catch (error) {
      console.error('Failed to reject request', error);
    }
  };

  return (
    <div className="cancellation-requests">
      <HeaderPages title="Cancellation Requests" onBack={() => navigate('/dashboard')} />
      <div className="requests-content">
        <div className="pending-requests-section">
          <h2>Pending Cancellation Requests</h2>
          {loading ? (
            <p>Loading...</p>
          ) : pendingRequests.length > 0 ? (
            <RequestsTable
              requests={pendingRequests}
              onApprove={handleApprove}
              onReject={handleReject}
            />
          ) : (
            <NoRequests />
          )}
        </div>
        <StatsSection stats={stats} />
      </div>
    </div>
  );
};

export default CancellationRequests;
