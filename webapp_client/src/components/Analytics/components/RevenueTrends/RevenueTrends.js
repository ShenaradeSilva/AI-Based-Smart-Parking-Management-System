import React, { useEffect, useState } from 'react';
import './RevenueTrends.css';
import API from '../../../../api/axios';
import analyticsData from '../../../../data/analyticsData';

const RevenueTrends = () => {
  const [trends, setTrends] = useState({
    avg_per_slot: 0,
    peak_hour_rate: 0,
    offpeak_rate: 0
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchTrends = async () => {
      try {
        const response = await API.get('/analytics/dashboard');
        const data = response.data;

        setTrends({
          avg_per_slot: data.revenue_trends?.avg_per_slot ?? 0,
          peak_hour_rate: data.revenue_trends?.peak_hour_rate ?? 0,
          offpeak_rate: data.revenue_trends?.offpeak_rate ?? 0
        });
      } catch (error) {
        console.error('Error fetching revenue trends, using mock data:', error);
        // Use mock data fallback
        const mock = analyticsData.revenue_trends ?? {
          avg_per_slot: 22450,
          peak_hour_rate: 15000,
          offpeak_rate: 8000
        };
        setTrends(mock);
      } finally {
        setLoading(false);
      }
    };

    fetchTrends();
  }, []);

  if (loading) {
    return <div className="revenue-trends">Loading revenue trends...</div>;
  }

  return (
    <div className="revenue-trends">
      <h3>Revenue Trends</h3>
      <div className="trend-item">
        <p>Average per slot/day:</p>
        <p className="trend-value">RS: {trends.avg_per_slot.toLocaleString()}</p>
      </div>
      <div className="trend-item">
        <p>Peak hour rate:</p>
        <p className="trend-value">RS: {trends.peak_hour_rate.toLocaleString()} / hour</p>
      </div>
      <div className="trend-item">
        <p>Off-peak rate:</p>
        <p className="trend-value">RS: {trends.offpeak_rate.toLocaleString()} / hour</p>
      </div>
    </div>
  );
};

export default RevenueTrends;
