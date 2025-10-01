import React, { useEffect, useState } from 'react';
import VehicleTable from '../VehicleTable/VehicleTable';
import API from '../../../../api/axios';
import analyticsData from '../../../../data/analyticsData'; 
import './AnalysisSection.css';

const AnalysisSection = ({ vehicleData: propVehicleData }) => {
  const [vehicleData, setVehicleData] = useState(propVehicleData || []);

  useEffect(() => {
    const fetchVehicleData = async () => {
      try {
        // Call backend API for real data
        const response = await API.get('/analytics/vehicle-visit-frequency');
        if (response.data && Array.isArray(response.data)) {
          setVehicleData(response.data);
        } else {
          console.warn('Unexpected response format, using mock data.');
          setVehicleData(analyticsData.vehicle_visit_frequency); // fallback to mock data
        }
      } catch (error) {
        console.error('Error fetching vehicle data:', error);
        setVehicleData(analyticsData.vehicle_visit_frequency); // fallback to mock data
      }
    };

    // Only fetch if parent did not provide data as prop
    if (!propVehicleData || propVehicleData.length === 0) {
      fetchVehicleData();
    }
  }, [propVehicleData]);

  return (
    <div className="analysis-section">
      <h3>Top Frequent Visitors</h3>
      <VehicleTable data={vehicleData} />
    </div>
  );
};

export default AnalysisSection;
