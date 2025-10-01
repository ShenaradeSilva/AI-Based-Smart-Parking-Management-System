import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './Analytics.css';
import StatsGrid from './components/StatsGrid/StatsGrid';
import RevenueTrends from './components/RevenueTrends/RevenueTrends';
import PerformanceMetrics from './components/PerformanceMetrics/PerformanceMetrics';
import HeaderPages from "../Common/HeaderPages";
import API from '../../api/axios';
import analyticsData from '../../data/analyticsData'; 

const Analytics = () => {
  const navigate = useNavigate();
  const [data, setData] = useState(analyticsData); // Start with mock data
  const [loading, setLoading] = useState(true);

  const handleBackToDashboard = () => {
    navigate('/dashboard');
  };

  useEffect(() => {
    const fetchData = async () => {
      try {
        // ✅ FIX: use the correct endpoint from your backend
        const response = await API.get('/api/dashboard/');
        setData(response.data);
      } catch (error) {
        console.error('Error fetching analytics data, using mock data:', error);
        setData(analyticsData); // fallback to mock data
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  if (loading) {
    return <div className="analytics-container">Loading analytics...</div>;
  }

  return (
    <div className="analytics-container">
      <HeaderPages
        title="Analytics"
        onBack={handleBackToDashboard}
      />
      
      <StatsGrid revenue={data.revenue} />
      
      <div className="analytics-content">
        <div className="analytics-main">
          <div className="analytics-main-content">
            <RevenueTrends trends={data.trends?.trends || []} predictions={data.predictions} />
            <PerformanceMetrics occupancy={data.occupancy} />
          </div>
        </div>
      </div>
    </div>
  );
};

export default Analytics;
