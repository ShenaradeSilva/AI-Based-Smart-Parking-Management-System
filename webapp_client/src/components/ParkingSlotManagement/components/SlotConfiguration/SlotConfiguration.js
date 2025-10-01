import React from 'react';
import Filters from '../Filters/Filters';
import './SlotConfiguration.css';
import { AddIcon, EditIcon, DeleteIcon } from '../../../Icons/Icons';

const SlotConfiguration = ({
  locations,
  slots,
  selectedLocation,
  dateFilter,
  timeFilter,
  onLocationChange,
  onDateFilterChange,
  onTimeFilterChange,
  onClearFilters,
  onEditSlot,
  onDeleteSlot,
  onAddSlot,
  onAddLocation
}) => {
  const getStatusClass = (status) => {
    switch(status?.toLowerCase()) {
      case 'available': return 'status-available';
      case 'occupied': return 'status-occupied';
      case 'maintenance': return 'status-maintenance';
      case 'reserved': return 'status-reserved';
      default: return '';
    }
  };

  const getLocationName = (slot) => {
    // Works for both mock and backend
    if (slot.location_name) return slot.location_name;
    if (slot.location) return slot.location;
    const loc = locations.find(l => l.location_id === slot.parking_lot_id || l.id === slot.parking_lot_id);
    return loc ? loc.name : 'Unknown';
  };

  const getSlotId = (slot) => slot.parking_slot_id || slot.id;

  const getLastUpdated = (slot) => {
    if (slot.updated_at) return new Date(slot.updated_at).toLocaleString();
    if (slot.lastUpdated) return slot.lastUpdated;
    return '-';
  };

  return (
    <div className="slot-configuration">
      <div className="section-header">
        <h2>Slot Configuration</h2>
        <div className="action-buttons">
          <button className="add-button" onClick={onAddSlot}>
            <AddIcon /> Add Slot
          </button>
          <button className="add-button" onClick={onAddLocation}>
            <AddIcon /> Add Location
          </button>
        </div>
      </div>

      <Filters
        locations={locations}
        selectedLocation={selectedLocation}
        dateFilter={dateFilter}
        timeFilter={timeFilter}
        onLocationChange={onLocationChange}
        onDateFilterChange={onDateFilterChange}
        onTimeFilterChange={onTimeFilterChange}
        onClearFilters={onClearFilters}
      />

      <div className="configuration-table">
        <div className="table-header">
          <div>Location</div>
          <div>Slot ID</div>
          <div>Status</div>
          <div>Last Updated</div>
          <div>Actions</div>
        </div>

        {slots.map(slot => (
          <div key={getSlotId(slot)} className="table-row">
            <div>{getLocationName(slot)}</div>
            <div>{getSlotId(slot)}</div>
            <div className={`status ${getStatusClass(slot.status)}`}>
              {slot.status || 'Available'}
            </div>
            <div>{getLastUpdated(slot)}</div>
            <div className="action-buttons">
              <button className="edit-button" onClick={() => onEditSlot(slot)}>
                <EditIcon /> Edit
              </button>
              <button className="delete-button" onClick={() => onDeleteSlot(getSlotId(slot))}>
                <DeleteIcon /> Delete
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default SlotConfiguration;
