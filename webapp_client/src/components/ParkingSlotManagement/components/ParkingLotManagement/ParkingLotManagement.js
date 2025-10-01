import React, { useEffect, useState } from 'react';
import StatusLegend from '../StatusLegend/StatusLegend';
import './ParkingLotManagement.css';
import { AddIcon, DeleteIcon, EditIcon } from '../../../Icons/Icons';
import API from '../../../../api/axios';
import locationsData from '../../../../data/locations';
import slotsData from '../../../../data/slots';

const ParkingLotManagement = ({
  selectedLocation,
  operationMode,
  onOperationModeChange,
  onSlotClick,   // open Add/Edit modal or notify parent
  onAddSlot      // parent handler for adding/updating slots
}) => {
  const [locations, setLocations] = useState([]);
  const [slots, setSlots] = useState([]);

  const getStatusClass = (status) => {
    switch (status) {
      case 'Available': return 'status-available';
      case 'Occupied': return 'status-occupied';
      case 'Maintenance': return 'status-maintenance';
      case 'Reserved': return 'status-reserved';
      default: return '';
    }
  };

  // Fetch backend data and normalize
  const fetchData = async () => {
    try {
      const [locationsRes, slotsRes] = await Promise.all([
        API.get('/api/parking/locations'),
        API.get('/api/parking/slots')
      ]);

      const mergedLocations = [
        ...locationsData,
        ...locationsRes.data.filter(
          loc => !locationsData.find(l => l.location_id === loc.location_id)
        )
      ];

      const mergedSlots = (slotsRes.data.length ? slotsRes.data : slotsData).map(slot => {
        const loc = mergedLocations.find(l => l.location_id === slot.parking_lot_id);
        return {
          id: slot.id ?? Date.now(),
          slotNumber: slot.slot_number ?? slot.id ?? 'N/A',
          location: loc ? loc.name : 'Unknown',
          status: slot.status ?? 'Available',
          lastUpdated: slot.lastUpdated ?? new Date().toISOString(),
        };
      });

      setLocations(mergedLocations);
      setSlots(mergedSlots);
    } catch (err) {
      console.error('Error fetching parking data', err);
      setLocations(locationsData);
      setSlots(
        slotsData.map(slot => {
          const loc = locationsData.find(l => l.location_id === slot.parking_lot_id);
          return {
            id: slot.id ?? Date.now(),
            slotNumber: slot.id ?? 'N/A',
            location: loc ? loc.name : 'Unknown',
            status: slot.status ?? 'Available',
            lastUpdated: slot.lastUpdated ?? new Date().toISOString(),
          };
        })
      );
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const filteredLocations =
    selectedLocation === 'All Locations'
      ? locations
      : locations.filter(loc => loc.name === selectedLocation);

  const groupedSlots = (locationName) => {
    const locationSlots = slots.filter(slot => slot.location === locationName);
    const rows = [];
    for (let i = 0; i < locationSlots.length; i += 3) {
      rows.push(locationSlots.slice(i, i + 3));
    }
    return rows;
  };

  // Handle click on slot depending on operation mode
  const handleSlotClick = async (slot) => {
    if (!slot) return;

    if (operationMode === 'edit') {
      onSlotClick(slot); // open modal with slot
    } else if (operationMode === 'delete') {
      if (window.confirm('Are you sure you want to delete this slot?')) {
        try {
          await API.delete(`/api/parking/slots/${slot.id}`);
          onSlotClick({ type: 'delete', slotId: slot.id });
        } catch (err) {
          console.error('Error deleting slot', err);
        }
      }
    } else {
      // Toggle status safely
      const newStatus = slot.status === 'Available' ? 'Occupied' : 'Available';
      try {
        await API.put(`/api/parking/slots/${slot.id}/status`, {
          status: newStatus ? newStatus.toLowerCase() : 'available' // fallback to available
        });

        onSlotClick({ type: 'status', slotId: slot.id, newStatus });
      } catch (err) {
        console.error('Error updating slot status', err);
      }
    }
  };

  return (
    <div className="parking-lot-management">
      <div className="section-header">
        <h2>Parking Lot Management</h2>
        <div className="action-buttons">
          <button className="add-button" onClick={() => handleSlotClick(null)}>
            <span><AddIcon /></span> Add Slot
          </button>
          <button
            className={operationMode === 'edit' ? 'edit-mode-active' : 'edit-button'}
            onClick={() => onOperationModeChange(operationMode === 'edit' ? null : 'edit')}
          >
            <span><EditIcon /></span> {operationMode === 'edit' ? 'Cancel Edit' : 'Edit Slot'}
          </button>
          <button
            className={operationMode === 'delete' ? 'delete-mode-active' : 'delete-button'}
            onClick={() => onOperationModeChange(operationMode === 'delete' ? null : 'delete')}
          >
            <span><DeleteIcon /></span> {operationMode === 'delete' ? 'Cancel Delete' : 'Delete Slot'}
          </button>
        </div>
      </div>

      <div className="operation-mode-indicator">
        {operationMode === 'edit' && <div className="mode-indicator edit-mode">Click a slot to edit</div>}
        {operationMode === 'delete' && <div className="mode-indicator delete-mode">Click a slot to delete</div>}
      </div>

      {filteredLocations.map(location => (
        <div key={location.location_id} className="location-section">
          <h3>{location.name}</h3>
          <div className="parking-lot">
            {groupedSlots(location.name).map((row, rowIndex) => (
              <div key={rowIndex} className="parking-row">
                {row.map(slot => (
                  <div
                    key={slot.id}
                    className={`parking-slot ${getStatusClass(slot.status)} ${operationMode ? 'operation-mode' : ''}`}
                    onClick={() => handleSlotClick(slot)}
                  >
                    <div className="slot-number">{slot.slotNumber}</div>
                    <div className="slot-status">{slot.status}</div>
                    {operationMode && (
                      <div className="slot-operation-hint">
                        {operationMode === 'edit' ? 'Click to edit' : 'Click to delete'}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            ))}
          </div>
        </div>
      ))}

      <StatusLegend />
    </div>
  );
};

export default ParkingLotManagement;
