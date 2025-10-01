import React, { useEffect, useState } from 'react';
import API from '../../../../api/axios'; // Axios instance for backend calls
import analyticsData from '../../../../data/analyticsData';
import './AIPredictions.css';

const AIPredictions = () => {
  const [data, setData] = useState(analyticsData); // default to mock data

  useEffect(() => {
    // Fetch data from backend (if available)
    API.get('/analytics/dashboard')
      .then(response => {
        if (response.data) setData(response.data);
      })
      .catch(err => {
        console.warn('Using mock data due to backend error:', err);
      });
  }, []);

  const { ai_predictions, weekly_trend, recommendation, capacity_alert, suggestion } = data;

  return (
    <div className="section">
      <h3>AI Predictions</h3>

      <div className="prediction-card">
        <p><strong>Tomorrow's Peak:</strong> {ai_predictions?.tomorrow_peak}</p>
        <p><strong>Expected:</strong> {ai_predictions?.expected}</p>
      </div>

      <div className="recommendation-card">
        <p><strong>Weekly Trend:</strong> {weekly_trend}</p>
        <p><strong>Recommendation:</strong> {recommendation}</p>
      </div>

      <div className="alert-card">
        <p><strong>Capacity Alert:</strong> {capacity_alert}</p>
        <p><strong>Suggestion:</strong> {suggestion}</p>
      </div>
    </div>
  );
};

export default AIPredictions;
