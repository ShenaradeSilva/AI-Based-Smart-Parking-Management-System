import React, { useEffect, useState } from 'react';
import './StatsGrid.css';
import API from '../../../../api/axios'; 
import analyticsData from '../../../../data/analyticsData'; 

const StatsGrid = () => {
  const [revenueStats, setRevenueStats] = useState({
    today: 0,
    week: 0,
    month: 0,
    growth_rate: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchRevenueStats = async () => {
      try {
        const response = await API.get('/analytics/dashboard');
        const data = response.data;

        setRevenueStats({
          today: data.revenue_stats?.today ?? 0,
          week: data.revenue_stats?.week ?? 0,
          month: data.revenue_stats?.month ?? 0,
          growth_rate: data.revenue_stats?.growth_rate ?? 0,
        });
      } catch (error) {
        console.error('Error fetching revenue stats, using mock data:', error);
        // Map mock data to expected keys
        const mock = analyticsData.revenue;
        setRevenueStats({
          today: mock.today ?? 22450,
          week: mock.week ?? 100850,
          month: mock.month ?? 900500,
          growth_rate: mock.growth_rate ?? 16,
        });
      } finally {
        setLoading(false);
      }
    };

    fetchRevenueStats();
  }, []);

  if (loading) {
    return <div className="analytics-grid">Loading revenue stats...</div>;
  }

  return (
    <div className="analytics-grid">
      <div className="analytics-card">
        <h3>RS: {revenueStats.today.toLocaleString()}</h3>
        <p>Today's Revenue</p>
      </div>

      <div className="analytics-card">
        <h3>RS: {revenueStats.week.toLocaleString()}</h3>
        <p>This Week</p>
      </div>

      <div className="analytics-card">
        <h3>RS: {revenueStats.month.toLocaleString()}</h3>
        <p>This Month</p>
      </div>

      <div className="analytics-card">
        <h3>{revenueStats.growth_rate > 0 ? `+${revenueStats.growth_rate}` : revenueStats.growth_rate}%</h3>
        <p>Growth Rate</p>
      </div>
    </div>
  );
};

export default StatsGrid;
