import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './PeakTimeAnalysis.css';
import HistoricalPeakTimes from './components/HistoricalPeakTimes/HistoricalPeakTimes';
import UsagePredictionChart from './components/UsagePredictionChart/UsagePredictionChart';
import AIPredictions from './components/AIPredictions/AIPredictions';
import HeaderPages from '../Common/HeaderPages';
import analyticsData from '../../data/analyticsData';
import API from '../../api/axios';

const PeakTimeAnalysis = () => {
  const navigate = useNavigate();
  const [peakData, setPeakData] = useState(null);

  const handleBackToDashboard = () => {
    navigate('/dashboard');
  };

  useEffect(() => {
    // Fetch from backend using axios
    API.get('/api/analytics/peak-times')
      .then(response => setPeakData(response.data))
      .catch(err => {
        console.warn('Backend not available, using mock data:', err);
        setPeakData(analyticsData); // fallback to mock data
      });
  }, []);

  if (!peakData) return <div>Loading Peak Time Analytics...</div>;

  return (
    <div className="peak-time-analysis">
      <HeaderPages
        title="Peak Time Analysis"
        onBack={handleBackToDashboard}
      />
      
      <div className="peak-time-content">
        <HistoricalPeakTimes 
          data={peakData.historical} 
          highestDemand={peakData.highest_demand} 
        />
        <UsagePredictionChart 
          data={peakData.ai_predictions} 
          predictions={peakData.predictions} 
        />
        <AIPredictions
          aiData={peakData.ai_predictions}
          weeklyTrend={peakData.weekly_trend}
          recommendation={peakData.recommendation}
          capacityAlert={peakData.capacity_alert}
          suggestion={peakData.suggestion}
          occupancy={peakData.occupancy}
        />
      </div>
    </div>
  );
};

export default PeakTimeAnalysis;
