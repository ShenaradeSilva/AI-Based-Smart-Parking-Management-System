import React, { useEffect, useState } from 'react';
import API from '../../../../api/axios';
import analyticsData from '../../../../data/analyticsData';
import './HistoricalPeakTimes.css';

const HistoricalPeakTimes = () => {
  const [peakData, setPeakData] = useState({
    weekdays_peak: '',
    weekend_peak: '',
    highest_demand: ''
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchPeakData = async () => {
      try {
        const response = await API.get('/analytics/peak-times');
        if (response.data) {
          setPeakData(response.data);
        } else {
          // fallback to mock data
          setPeakData({
            weekdays_peak: analyticsData.historical.weekdays_peak,
            weekend_peak: analyticsData.historical.weekend_peak,
            highest_demand: analyticsData.highest_demand
          });
        }
      } catch (err) {
        setPeakData({
          weekdays_peak: analyticsData.historical.weekdays_peak,
          weekend_peak: analyticsData.historical.weekend_peak,
          highest_demand: analyticsData.highest_demand
        });
        setError('Failed to fetch backend data. Showing mock data.');
      } finally {
        setLoading(false);
      }
    };

    fetchPeakData();
  }, []);

  if (loading) return <p style={{ textAlign: 'center' }}>Loading peak times...</p>;

  return (
    <div className="section">
      <h3>Historical Peak Times</h3>
      {error && <p style={{ color: 'red', fontSize: '0.9rem' }}>{error}</p>}
      <div className="info-card">
        <p><strong>Weekdays Peak:</strong> {peakData.weekdays_peak}</p>
        <p><strong>Weekend Peak:</strong> {peakData.weekend_peak}</p>
        <p><strong>Highest Demand:</strong> {peakData.highest_demand}</p>
      </div>
    </div>
  );
};

export default HistoricalPeakTimes;
