import React, { useEffect, useState } from 'react';
import './InsightsSection.css';
import API from '../../../../api/axios'; 
import analyticsData from '../../../../data/analyticsData'; 

const InsightsSection = ({ initialInsights = [] }) => {
  const [insights, setInsights] = useState(initialInsights);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchInsights = async () => {
      try {
        setLoading(true);
        // API endpoint for insights (backend)
        const res = await API.get('/api/analytics/visit-frequency'); 
        const apiData = res.data;

        // Transform backend data into insight format
        const transformedInsights = [
          {
            title: 'Most Frequent Vehicle',
            description: `Vehicle ${apiData.most_frequent_vehicle?.vehicle_id || 'N/A'} visited ${apiData.most_frequent_vehicle?.visits || 0} times`
          },
          {
            title: 'Total Vehicles',
            description: `${apiData.total_vehicles || 0} unique vehicles visited`
          },
          // Add more insights based on backend data if needed
        ];

        setInsights(transformedInsights);
      } catch (error) {
        console.error('Failed to fetch insights from backend, using mock data.', error);
        // Fallback to mock data
        setInsights(analyticsData.vehicleVisitFrequency.insights);
      } finally {
        setLoading(false);
      }
    };

    // Only fetch if no initialInsights provided
    if (initialInsights.length === 0) {
      fetchInsights();
    } else {
      setLoading(false);
    }
  }, [initialInsights]);

  if (loading) {
    return <p className="loading-message">Loading insights...</p>;
  }

  return (
    <div className="insights-section">
      <h3>AI-Generated Insights & Recommendations</h3>
      {insights.map((insight, index) => (
        <div key={index} className="insight-card">
          <h4>{insight.title}</h4>
          <p>{insight.description}</p>
        </div>
      ))}
    </div>
  );
};

export default InsightsSection;
