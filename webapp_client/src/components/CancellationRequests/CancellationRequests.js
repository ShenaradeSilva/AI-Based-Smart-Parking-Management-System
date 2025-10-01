import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import API from '../../api/axios'; // axios instance
import './CancellationRequests.css';
import RequestsTable from './components/RequestsTable/RequestsTable';
import StatsSection from './components/StatsSection/StatsSection';
import NoRequests from './components/NoRequests/NoRequests';
import HeaderPages from '../Common/HeaderPages';
import cancellationRequestsData from '../../data/cancellationRequestsData'; // mock data

const CancellationRequests = () => {
  const navigate = useNavigate();
  const [pendingRequests, setPendingRequests] = useState([]);
  const [stats, setStats] = useState({ todayRequests: 0, approvalRate: 0 });
  const [loading, setLoading] = useState(true);

  // Fetch pending requests from backend or fallback to mock data
  const fetchPendingRequests = async () => {
    try {
      const res = await API.get('/cancellations/pending');
      setPendingRequests(res.data);
    } catch (error) {
      console.warn('Backend fetch failed, using mock data', error);
      setPendingRequests(cancellationRequestsData);
    }
  };

  // Fetch stats from backend or fallback to mock stats
  const fetchStats = async () => {
    try {
      const res = await API.get('/cancellations/stats');
      setStats(res.data);
    } catch (error) {
      console.warn('Backend fetch failed, using mock stats', error);
      setStats({
        todayRequests: cancellationRequestsData.length,
        approvalRate: 89,
      });
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
      await API.post(`/cancellations/${requestId}/approve`);
      setPendingRequests(prev => prev.filter(r => r.id !== requestId));
      setStats(prev => ({ ...prev, todayRequests: prev.todayRequests - 1 }));
    } catch (error) {
      console.warn('Backend approve failed, updating mock data', error);
      setPendingRequests(prev => prev.filter(r => r.id !== requestId));
      setStats(prev => ({ ...prev, todayRequests: prev.todayRequests - 1 }));
    }
  };

  const handleReject = async (requestId) => {
    try {
      await API.post(`/cancellations/${requestId}/reject`);
      setPendingRequests(prev => prev.filter(r => r.id !== requestId));
      setStats(prev => ({ ...prev, todayRequests: prev.todayRequests - 1 }));
    } catch (error) {
      console.warn('Backend reject failed, updating mock data', error);
      setPendingRequests(prev => prev.filter(r => r.id !== requestId));
      setStats(prev => ({ ...prev, todayRequests: prev.todayRequests - 1 }));
    }
  };

  const handleBackToDashboard = () => navigate('/dashboard');

  return (
    <div className="cancellation-requests">
      <HeaderPages title="Cancellation Requests" onBack={handleBackToDashboard} />

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
