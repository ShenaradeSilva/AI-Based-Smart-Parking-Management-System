import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './VehicleVisitFrequency.css';
import AnalysisSection from './components/AnalysisSection/AnalysisSection';
import InsightsSection from './components/InsightsSection/InsightsSection';
import HeaderPages from '../Common/HeaderPages';
import API from '../../api/axios';
import analyticsData from '../../data/analyticsData'; 

const VehicleVisitFrequency = () => {
  const navigate = useNavigate();
  const [vehicleData, setVehicleData] = useState([]);
  const [insightsData, setInsightsData] = useState([]);
  const [loading, setLoading] = useState(true);

  const handleBackToDashboard = () => {
    navigate('/dashboard');
  };

  useEffect(() => {
    const fetchVehicleVisitFrequency = async () => {
      try {
        setLoading(true);
        const res = await API.get('/api/analytics/visit-frequency');

        const apiData = res.data;

        const transformedVehicleData = apiData.daily_visits.map((item, index) => ({
          vehicle: index === 0 && apiData.most_frequent_vehicle.vehicle_id 
            ? apiData.most_frequent_vehicle.vehicle_id 
            : `Vehicle-${index + 1}`,
          totalVisits: item.visits,
          preferredSlot: 'N/A',
          avgDuration: 'N/A'
        }));

        const generatedInsights = [
          {
            title: 'Most Frequent Vehicle',
            description: `Vehicle ${apiData.most_frequent_vehicle.vehicle_id || 'N/A'} visited ${apiData.most_frequent_vehicle.visits} times in last 30 days`
          },
          {
            title: 'Total Vehicles',
            description: `${apiData.total_vehicles} unique vehicles visited in last 30 days`
          }
        ];

        setVehicleData(transformedVehicleData);
        setInsightsData(generatedInsights);
      } catch (error) {
        console.error('Failed to fetch vehicle visit frequency, using mock data.', error);
        setVehicleData(analyticsData.vehicleVisitFrequency.vehicles);
        setInsightsData(analyticsData.vehicleVisitFrequency.insights);
      } finally {
        setLoading(false);
      }
    };

    fetchVehicleVisitFrequency();
  }, []);

  if (loading) {
    return (
      <div className="vehicle-visit-frequency">
        <HeaderPages title="Vehicle Visit Frequencies" onBack={handleBackToDashboard} />
        <p className="loading-message">Loading vehicle visit data...</p>
      </div>
    );
  }

  return (
    <div className="vehicle-visit-frequency">
      <HeaderPages title="Vehicle Visit Frequencies" onBack={handleBackToDashboard} />

      <AnalysisSection vehicleData={vehicleData} />
      <InsightsSection insights={insightsData} />
    </div>
  );
};

export default VehicleVisitFrequency;
