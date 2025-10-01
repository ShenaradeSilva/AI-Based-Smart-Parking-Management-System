import React, { useState, useEffect, useMemo } from 'react';
import {
  ResponsiveContainer, BarChart, Bar,
  LineChart, Line, XAxis, YAxis, Tooltip, CartesianGrid, Legend
} from 'recharts';
import API from '../../../../api/axios';
import analyticsData from '../../../../data/analyticsData'; 
import './UsagePredictionChart.css';

const UsagePredictionChart = () => {
  const [chartType, setChartType] = useState('bar');
  const [timePeriod, setTimePeriod] = useState('day'); // Only 'day' or 'week' supported
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchAnalytics = async () => {
      try {
        const response = await API.get('/api/analytics/dashboard');
        const trends = response.data?.trends || analyticsData.trends;
        const predictions = response.data?.predictions || analyticsData.predictions;

        const merged = [
          ...trends.map(t => ({ date: t.date, reservations: t.reservations_count, type: 'Historical' })),
          ...predictions.map(p => ({ date: p.date, reservations: p.predicted_reservations, type: 'Predicted' }))
        ];

        setData(merged);
      } catch (err) {
        console.warn('Using mock data', err);
        const merged = [
          ...analyticsData.trends.map(t => ({ date: t.date, reservations: t.reservations_count, type: 'Historical' })),
          ...analyticsData.predictions.map(p => ({ date: p.date, reservations: p.predicted_reservations, type: 'Predicted' }))
        ];
        setData(merged);
      } finally {
        setLoading(false);
      }
    };

    fetchAnalytics();
  }, []);

  const filteredData = useMemo(() => {
    if (!data.length) return [];

    if (timePeriod === 'week') {
      // Aggregate weekly
      const weeklyAgg = {};
      data.forEach(item => {
        const dt = new Date(item.date);
        const weekStart = new Date(dt.setDate(dt.getDate() - dt.getDay()));
        const key = weekStart.toISOString().split('T')[0] + '-' + item.type;
        weeklyAgg[key] = weeklyAgg[key] || { date: weekStart.toISOString().split('T')[0], reservations: 0, type: item.type };
        weeklyAgg[key].reservations += item.reservations;
      });
      return Object.values(weeklyAgg).sort((a,b) => new Date(a.date) - new Date(b.date));
    }

    // Daily
    return [...data].sort((a,b) => new Date(a.date) - new Date(b.date));
  }, [data, timePeriod]);

  if (loading) return <p style={{ textAlign: 'center', marginTop: 50 }}>Loading chart...</p>;
  if (!filteredData.length) return <p style={{ textAlign: 'center', marginTop: 50 }}>No data available</p>;

  return (
    <div className="section">
      <h3>Peak Usage Prediction Chart</h3>

      <div className="chart-controls">
        <div>
          <label>Chart Type: </label>
          <select value={chartType} onChange={e => setChartType(e.target.value)}>
            <option value="bar">Bar</option>
            <option value="line">Line</option>
          </select>
        </div>
        <div>
          <label>Time Period: </label>
          <select value={timePeriod} onChange={e => setTimePeriod(e.target.value)}>
            <option value="day">Daily</option>
            <option value="week">Weekly</option>
          </select>
        </div>
      </div>

      <div className="chart-card" style={{ width: '100%', height: 350 }}>
        <ResponsiveContainer width="100%" height="100%">
          {chartType === 'bar' ? (
            <BarChart data={filteredData} margin={{ top: 20, right: 20, left: 0, bottom: 5 }}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="date" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="reservations" fill="#8884d8" />
            </BarChart>
          ) : (
            <LineChart data={filteredData} margin={{ top: 20, right: 20, left: 0, bottom: 5 }}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="date" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="reservations" stroke="#82ca9d" />
            </LineChart>
          )}
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default UsagePredictionChart;
