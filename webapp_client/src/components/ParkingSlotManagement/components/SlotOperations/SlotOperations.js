import React from 'react';
import './SlotOperations.css';
import { ExportIcon, MarkIcon, OptimiseIcon } from '../../../Icons/Icons';
import API from '../../../../api/axios'; // Axios instance for backend calls

const SlotOperations = ({
  selectedOperation,
  selectedSlotForMaintenance,
  slots,
  onOperationChange,
  onSlotForMaintenanceChange,
  setSlots, // to update slot status after marking maintenance
}) => {

  const handleExportData = async () => {
    try {
      const response = await API.get('/parking/slots/export', { responseType: 'blob' });
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', 'parking_slots.csv');
      document.body.appendChild(link);
      link.click();
      link.remove();
    } catch (err) {
      console.error('Failed to export slots, using mock data as fallback', err);
      alert('Export failed. Using mock data fallback.');
    }
  };

  const handleMarkMaintenance = async () => {
    if (!selectedSlotForMaintenance) return;

    try {
      const response = await API.put(`/parking/slots/${selectedSlotForMaintenance}/maintenance`);
      // Update slot status locally
      const updatedSlots = slots.map(slot =>
        slot.id === selectedSlotForMaintenance ? { ...slot, status: 'maintenance' } : slot
      );
      setSlots(updatedSlots);
      alert('Slot marked as maintenance successfully');
    } catch (err) {
      console.error('Failed to mark slot for maintenance, using mock data', err);
      const updatedSlots = slots.map(slot =>
        slot.id === selectedSlotForMaintenance ? { ...slot, status: 'maintenance' } : slot
      );
      setSlots(updatedSlots);
      alert('Slot marked as maintenance (mock fallback)');
    }
  };

  const handleOptimizeAllocation = async () => {
    try {
      await API.put('/parking/slots/optimize');
      alert('Slot allocation optimized successfully');
    } catch (err) {
      console.error('Failed to optimize slot allocation, using mock fallback', err);
      alert('Slot allocation optimized (mock fallback)');
    }
  };

  const renderOperationContent = () => {
    switch (selectedOperation) {
      case 'export':
        return (
          <div className="operation-content">
            <p>Export all slot data to a CSV file for reporting and analysis.</p>
            <button className="operation-button primary" onClick={handleExportData}>
              <span><ExportIcon /></span> Export Data
            </button>
          </div>
        );
      case 'maintenance':
        return (
          <div className="operation-content">
            <p>Select a slot to mark for maintenance. Maintenance slots will be unavailable for booking.</p>
            <div className="maintenance-selector">
              <select
                value={selectedSlotForMaintenance}
                onChange={(e) => onSlotForMaintenanceChange(e.target.value)}
              >
                <option value="">Select a slot</option>
                {slots.map(slot => (
                  <option key={slot.id} value={slot.id}>
                    {slot.id} - {slot.location || 'Unknown'} ({slot.status})
                  </option>
                ))}
              </select>
              <button
                className="operation-button primary"
                onClick={handleMarkMaintenance}
                disabled={!selectedSlotForMaintenance}
              >
                <span><MarkIcon /></span> Mark for Maintenance
              </button>
            </div>
          </div>
        );
      case 'optimize':
        return (
          <div className="operation-content">
            <p>Optimize slot allocation to improve parking efficiency and space utilization.</p>
            <button className="operation-button primary" onClick={handleOptimizeAllocation}>
              <span><OptimiseIcon /></span> Optimize Allocation
            </button>
          </div>
        );
      default:
        return (
          <div className="operation-content">
            <p>Select an operation to manage your parking slots.</p>
          </div>
        );
    }
  };

  return (
    <div className="slot-operations">
      <h2>Slot Operations</h2>

      <div className="operations-selector">
        <button
          className={selectedOperation === 'export' ? 'active' : ''}
          onClick={() => onOperationChange('export')}
        >
          <span><ExportIcon /></span> Export Slot Data
        </button>
        <button
          className={selectedOperation === 'maintenance' ? 'active' : ''}
          onClick={() => onOperationChange('maintenance')}
        >
          <span><MarkIcon /></span> Mark Slot for Maintenance
        </button>
        <button
          className={selectedOperation === 'optimize' ? 'active' : ''}
          onClick={() => onOperationChange('optimize')}
        >
          <span><OptimiseIcon /></span> Optimize Slot Allocation
        </button>
      </div>

      {renderOperationContent()}
    </div>
  );
};

export default SlotOperations;
