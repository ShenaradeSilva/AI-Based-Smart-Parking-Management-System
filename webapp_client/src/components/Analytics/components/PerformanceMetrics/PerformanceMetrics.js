import React, { useEffect, useState } from 'react';
import './PerformanceMetrics.css';
import API from '../../../../api/axios';
import analyticsData from '../../../../data/analyticsData';

const PerformanceMetrics = () => {
  const [metrics, setMetrics] = useState({
    utilization_rate: 0,
    avg_stay_duration: 0
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchMetrics = async () => {
      try {
        const response = await API.get('/analytics/dashboard');
        const data = response.data;

        setMetrics({
          utilization_rate: data.performance_metrics?.utilization_rate ?? 0,
          avg_stay_duration: data.performance_metrics?.avg_stay_duration ?? 0
        });
      } catch (error) {
        console.error('Error fetching performance metrics, using mock data:', error);
        // Use mock data fallback
        const mock = analyticsData.performance_metrics ?? {
          utilization_rate: 95.8,
          avg_stay_duration: 2.4
        };
        setMetrics(mock);
      } finally {
        setLoading(false);
      }
    };

    fetchMetrics();
  }, []);

  if (loading) {
    return <div className="performance-metrics">Loading performance metrics...</div>;
  }

  return (
    <div className="performance-metrics">
      <h3>Performance Metrics</h3>
      <div className="metrics-grid">
        <div className="metric-item">
          <h4>{metrics.utilization_rate}%</h4>
          <p>Utilization Rate</p>
        </div>
        <div className="metric-item">
          <h4>{metrics.avg_stay_duration}h</h4>
          <p>Avg Stay Duration</p>
        </div>
      </div>
    </div>
  );
};

export default PerformanceMetrics;
