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

  // Export all slot data as CSV
  const handleExportData = async () => {
    try {
      const response = await API.get('/parking/slots/export', { responseType: 'blob' });

      // Trigger download
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', 'parking_slots.csv');
      document.body.appendChild(link);
      link.click();
      link.remove();

      alert('Slot data exported successfully.');
    } catch (err) {
      console.error('Error exporting slots:', err);
      alert('Failed to export slot data.');
    }
  };

  // Mark slot as maintenance
  const handleMarkMaintenance = async () => {
    if (!selectedSlotForMaintenance) return alert('Please select a slot.');

    try {
      const response = await API.put(`/parking/slots/${selectedSlotForMaintenance}/maintenance`);
      if (response.status === 200) {
        // Update slot status in local state
        const updatedSlots = slots.map(slot =>
          slot.id === selectedSlotForMaintenance
            ? { ...slot, status: 'maintenance' }
            : slot
        );
        setSlots(updatedSlots);
        alert('Slot marked as maintenance successfully.');
      } else {
        alert('Failed to mark slot for maintenance.');
      }
    } catch (err) {
      console.error('Error marking slot for maintenance:', err);
      alert('Error: Could not update slot status.');
    }
  };

  // Optimize slot allocation
  const handleOptimizeAllocation = async () => {
    try {
      const response = await API.put('/parking/slots/optimize');
      if (response.status === 200) {
        alert('Slot allocation optimized successfully.');
      } else {
        alert('Optimization process failed.');
      }
    } catch (err) {
      console.error('Error optimizing slot allocation:', err);
      alert('Error: Optimization failed.');
    }
  };

  // Render operation-specific content
  const renderOperationContent = () => {
    switch (selectedOperation) {
      case 'export':
        return (
          <div className="operation-content">
            <p>Export all parking slot data to a CSV file for reporting or analysis.</p>
            <button className="operation-button primary" onClick={handleExportData}>
              <ExportIcon /> Export Data
            </button>
          </div>
        );

      case 'maintenance':
        return (
          <div className="operation-content">
            <p>Select a slot to mark as under maintenance. These slots will not be available for booking.</p>
            <div className="maintenance-selector">
              <select
                value={selectedSlotForMaintenance}
                onChange={(e) => onSlotForMaintenanceChange(e.target.value)}
              >
                <option value="">Select a slot</option>
                {slots.map(slot => (
                  <option key={slot.id} value={slot.id}>
                    Slot {slot.id} — {slot.location || 'Unknown'} ({slot.status})
                  </option>
                ))}
              </select>
              <button
                className="operation-button primary"
                onClick={handleMarkMaintenance}
                disabled={!selectedSlotForMaintenance}
              >
                <MarkIcon /> Mark for Maintenance
              </button>
            </div>
          </div>
        );

      case 'optimize':
        return (
          <div className="operation-content">
            <p>Optimize parking slot allocation for better efficiency and space usage.</p>
            <button className="operation-button primary" onClick={handleOptimizeAllocation}>
              <OptimiseIcon /> Optimize Allocation
            </button>
          </div>
        );

      default:
        return (
          <div className="operation-content">
            <p>Select an operation to manage parking slots.</p>
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
          <ExportIcon /> Export Slot Data
        </button>

        <button
          className={selectedOperation === 'maintenance' ? 'active' : ''}
          onClick={() => onOperationChange('maintenance')}
        >
          <MarkIcon /> Mark Slot for Maintenance
        </button>

        <button
          className={selectedOperation === 'optimize' ? 'active' : ''}
          onClick={() => onOperationChange('optimize')}
        >
          <OptimiseIcon /> Optimize Slot Allocation
        </button>
      </div>

      {renderOperationContent()}
    </div>
  );
};

export default SlotOperations;
