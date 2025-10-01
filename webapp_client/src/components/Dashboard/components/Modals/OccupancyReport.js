import React, { useEffect, useState } from 'react';
import { CloseIcon } from '../../../Icons/Icons';
import './Modals.css';
import axios from 'axios';

const OccupancyReport = ({ onClose }) => {
  const [report, setReport] = useState(null);

  useEffect(() => {
    const fetchReport = async () => {
      try {
        const res = await axios.get('/api/reports/occupancy');
        setReport(res.data);
      } catch (err) {
        console.error('Failed to fetch occupancy report', err);
      }
    };
    fetchReport();
  }, []);

  if (!report) return <div className="modal-overlay"><div className="modal-content">Loading...</div></div>;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content report-modal" onClick={e => e.stopPropagation()}>
        <div className="modal-header">
          <h2>Occupancy Report</h2>
          <button className="close-button" onClick={onClose}>
            <CloseIcon />
          </button>
        </div>
        <div className="modal-body">
          <div className="report-summary">
            <h3>Current Occupancy: {report.currentOccupancy}%</h3>
          </div>

          <div className="report-section">
            <h4>Hourly Occupancy (Today)</h4>
            <div className="chart-container">
              {report.hourlyData.map((data, index) => (
                <div key={index} className="chart-bar">
                  <div
                    className="bar-fill"
                    style={{ height: `${data.occupancy}%` }}
                    title={`${data.hour}: ${data.occupancy}%`}
                  ></div>
                  <span className="bar-label">{data.hour}</span>
                </div>
              ))}
            </div>
          </div>

          <div className="report-section">
            <h4>Daily Average Occupancy (This Week)</h4>
            <table className="report-table">
              <thead>
                <tr>
                  <th>Day</th>
                  <th>Occupancy Rate</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {report.dailyData.map((data, index) => (
                  <tr key={index}>
                    <td>{data.day}</td>
                    <td>{data.occupancy}%</td>
                    <td>
                      <span className={`status-badge ${
                        data.occupancy > 80 ? 'high' :
                        data.occupancy > 50 ? 'medium' : 'low'
                      }`}>
                        {data.occupancy > 80 ? 'High' :
                         data.occupancy > 50 ? 'Medium' : 'Low'}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
};

export default OccupancyReport;
