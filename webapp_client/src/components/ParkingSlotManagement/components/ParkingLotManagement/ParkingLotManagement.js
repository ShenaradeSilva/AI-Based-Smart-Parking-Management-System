import React, { useEffect, useState } from 'react';
import StatusLegend from '../StatusLegend/StatusLegend';
import './ParkingLotManagement.css';
import { AddIcon, DeleteIcon, EditIcon } from '../../../Icons/Icons';
import API from '../../../../api/axios';
import AddSlotModal from '../Modals/AddSlotModal';

const ParkingLotManagement = ({
  selectedLocation,
  operationMode,
  onOperationModeChange,
  onSlotClick,   // open Edit modal
  adminId        // pass admin ID to AddSlotModal
}) => {
  const [locations, setLocations] = useState([]);
  const [slots, setSlots] = useState([]);
  const [showAddModal, setShowAddModal] = useState(false);
  const [editingSlot, setEditingSlot] = useState(null);

  const getStatusClass = (status) => {
    switch (status) {
      case 'Available': return 'status-available';
      case 'Occupied': return 'status-occupied';
      case 'Maintenance': return 'status-maintenance';
      case 'Reserved': return 'status-reserved';
      default: return '';
    }
  };

  // Fetch backend data
  const fetchData = async () => {
    try {
      const [locationsRes, slotsRes] = await Promise.all([
        API.get('/api/parking/locations'),
        API.get('/api/parking/slots')
      ]);

      setLocations(locationsRes.data || []);
      setSlots(
        (slotsRes.data || []).map(slot => ({
          id: slot.id,
          slotNumber: slot.slot_number,
          type: slot.slot_type ?? 'vehicle',
          location: locationsRes.data.find(l => l.location_id === slot.parking_lot_id)?.name ?? 'Unknown',
          status: slot.status ?? 'Available',
          lastUpdated: slot.lastUpdated ?? new Date().toISOString(),
        }))
      );
    } catch (err) {
      console.error('Error fetching parking data', err);
      setLocations([]);
      setSlots([]);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const filteredLocations =
    selectedLocation === 'All Locations'
      ? locations
      : locations.filter(loc => loc.name === selectedLocation);

  const groupedSlots = (locationName, type) => {
    const locationSlots = slots.filter(
      slot =>
        slot.location === locationName &&
        slot.type?.toLowerCase() === type.toLowerCase()
    );
    const rows = [];
    for (let i = 0; i < locationSlots.length; i += 3) {
      rows.push(locationSlots.slice(i, i + 3));
    }
    return rows;
  };

  // Handle slot clicks (edit, delete, toggle status)
  const handleSlotClick = async (slot) => {
    if (!slot) return;

    if (operationMode === 'edit') {
      setEditingSlot(slot);
      setShowAddModal(true); // open modal for editing
    } else if (operationMode === 'delete') {
      if (window.confirm('Are you sure you want to delete this slot?')) {
        try {
          await API.delete(`/api/parking/slots/${slot.id}`);
          fetchData();
        } catch (err) {
          console.error('Error deleting slot', err);
        }
      }
    } else {
      const newStatus = slot.status === 'Available' ? 'Occupied' : 'Available';
      try {
        await API.put(`/api/parking/slots/${slot.id}/status`, {
          status: newStatus.toLowerCase()
        });
        fetchData();
      } catch (err) {
        console.error('Error updating slot status', err);
      }
    }
  };

  // Open Add Slot modal
  const handleAddSlot = () => {
    setEditingSlot(null);
    setShowAddModal(true);
  };

  // Callback after adding/updating slot
  const handleSlotSave = (newSlot) => {
    fetchData(); // refresh slots after add/edit
    setShowAddModal(false);
  };

  return (
    <div className="parking-lot-management">
      <div className="section-header">
        <h2>Parking Lot Management</h2>
        <div className="action-buttons">
          <button className="add-button" onClick={handleAddSlot}>
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

          <div className="parking-lot-split">
            {/* Bike Slots */}
            <div className="bike-section">
              <h4>Bike Slots</h4>
              <div className="parking-lot">
                {groupedSlots(location.name, 'bike').map((row, rowIndex) => (
                  <div key={rowIndex} className="parking-row">
                    {row.map(slot => (
                      <div
                        key={slot.id}
                        className={`parking-slot bike-slot ${getStatusClass(slot.status)} ${operationMode ? 'operation-mode' : ''}`}
                        onClick={() => handleSlotClick(slot)}
                      >
                        <div className="slot-number">{slot.slotNumber}</div>
                        <div className="slot-status">{slot.status}</div>
                      </div>
                    ))}
                  </div>
                ))}
              </div>
            </div>

            {/* Vehicle Slots */}
            <div className="vehicle-section">
              <h4>Vehicle Slots</h4>
              <div className="parking-lot">
                {groupedSlots(location.name, 'vehicle').map((row, rowIndex) => (
                  <div key={rowIndex} className="parking-row">
                    {row.map(slot => (
                      <div
                        key={slot.id}
                        className={`parking-slot vehicle-slot ${getStatusClass(slot.status)} ${operationMode ? 'operation-mode' : ''}`}
                        onClick={() => handleSlotClick(slot)}
                      >
                        <div className="slot-number">{slot.slotNumber}</div>
                        <div className="slot-status">{slot.status}</div>
                      </div>
                    ))}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      ))}

      <StatusLegend />

      {showAddModal && (
        <AddSlotModal
          editingSlot={editingSlot}
          locations={locations}
          adminId={adminId}
          onClose={() => setShowAddModal(false)}
          onAddSlot={handleSlotSave}
        />
      )}
    </div>
  );
};

export default ParkingLotManagement;
