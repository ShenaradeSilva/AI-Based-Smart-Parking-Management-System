import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import API from '../../api/axios';
import './ParkingSlotManagement.css';
import SlotConfiguration from './components/SlotConfiguration/SlotConfiguration';
import ParkingLotManagement from './components/ParkingLotManagement/ParkingLotManagement';
import SlotOperations from './components/SlotOperations/SlotOperations';
import AddLocationModal from './components/Modals/AddLocationModal';
import AddSlotModal from './components/Modals/AddSlotModal';
import HeaderPages from '../Common/HeaderPages';

const ParkingSlotManagement = () => {
  const navigate = useNavigate();

  const [locations, setLocations] = useState([]);
  const [slots, setSlots] = useState([]);
  const [selectedLocation, setSelectedLocation] = useState('All Locations');
  const [selectedOperation, setSelectedOperation] = useState(null);
  const [selectedSlotForMaintenance, setSelectedSlotForMaintenance] = useState('');
  const [showAddLocationModal, setShowAddLocationModal] = useState(false);
  const [showAddSlotModal, setShowAddSlotModal] = useState(false);
  const [editingSlot, setEditingSlot] = useState(null);
  const [operationMode, setOperationMode] = useState(null);
  const [dateFilter, setDateFilter] = useState('');
  const [timeFilter, setTimeFilter] = useState('');

  // Get logged-in admin from localStorage
  const loggedInAdmin = {
    id: localStorage.getItem('admin_id') || 1,
    name: localStorage.getItem('admin_name') || 'Admin',
    token: localStorage.getItem('admin_token') || '', // if using JWT
  };

  // Normalize slot data to match frontend
  const normalizeSlots = (rawSlots, allLocations) =>
    rawSlots.map(slot => {
      const loc = allLocations.find(l => l.location_id === slot.parking_lot_id);
      return {
        ...slot,
        id: slot.id || slot.slot_id,
        location: loc ? loc.name : 'Unknown',
        status: slot.status || 'Available',
        lastUpdated: slot.updated_at || slot.lastUpdated || new Date().toISOString(),
      };
    });

  // Fetch all locations and slots from backend
  const fetchData = async () => {
    try {
      const [locationsRes, slotsRes] = await Promise.all([
        API.get('/api/locations/list'),
        API.get('/api/parking/slots/list'),
      ]);

      setLocations(locationsRes.data);
      setSlots(normalizeSlots(slotsRes.data, locationsRes.data));
    } catch (err) {
      console.error('Error fetching backend data:', err);
      setLocations([]);
      setSlots([]);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  // Add or edit a slot
  const handleAddSlot = async (newSlotData) => {
    if (editingSlot) {
      // Optimistic UI update
      setSlots(slots.map(slot => slot.id === editingSlot.id ? { ...slot, ...newSlotData } : slot));

      try {
        await API.put(`/api/parking/slots/${editingSlot.id}/status-update`, null, {
          params: { status: newSlotData.status.toLowerCase() },
        });
      } catch (err) {
        console.error('Error updating slot on backend', err);
      }
      setEditingSlot(null);
    } else {
      try {
        const res = await API.post('/api/parking/slots/add', {
          slot_number: newSlotData.slotNumber,
          parking_lot_id: locations.find(l => l.name === newSlotData.location)?.location_id,
          slot_type: 'standard',
          created_by: loggedInAdmin.id,
        });

        setSlots([...slots, {
          ...newSlotData,
          id: res.data.id,
          status: res.data.status || 'Available',
          lastUpdated: new Date().toISOString(),
        }]);
      } catch (err) {
        console.error('Error adding slot to backend', err);
      }
    }
    setShowAddSlotModal(false);
  };

  // Delete a slot
  const handleDeleteSlot = async (slotId) => {
    if (!window.confirm('Are you sure you want to delete this slot?')) return;
    try {
      await API.delete(`/api/parking/slots/${slotId}/delete`);
      setSlots(slots.filter(slot => slot.id !== slotId));
    } catch (err) {
      console.error('Error deleting slot on backend', err);
    }
  };

  // Edit a slot
  const handleEditSlot = (slot) => {
    setEditingSlot(slot);
    setShowAddSlotModal(true);
    setOperationMode(null);
  };

  // Change slot status
  const handleStatusChange = async (slotId, newStatus) => {
    setSlots(slots.map(slot => slot.id === slotId ? { ...slot, status: newStatus } : slot));
    try {
      await API.put(`/api/parking/slots/${slotId}/status-update`, null, {
        params: { status: newStatus.toLowerCase() },
      });
    } catch (err) {
      console.error('Error updating slot status', err);
    }
  };

  const handleSlotClick = (payload) => {
    if (!payload) return;
    if (payload.type === 'delete') handleDeleteSlot(payload.slotId);
    else if (payload.type === 'status') handleStatusChange(payload.slotId, payload.newStatus);
    else handleEditSlot(payload);
  };

  // Add a location
  const handleAddLocation = async (loc) => {
    try {
      const res = await API.post('/api/locations/create', loc, {
        headers: { Authorization: `Bearer ${loggedInAdmin.token}` },
      });
      setLocations([...locations, res.data]);
    } catch (err) {
      console.error('Error adding location to backend', err);
    }
    setShowAddLocationModal(false);
  };

  // Filter slots by location and date
  const filterSlots = () => {
    let filtered = slots;
    if (selectedLocation !== 'All Locations')
      filtered = filtered.filter(slot => slot.location === selectedLocation);
    if (dateFilter)
      filtered = filtered.filter(slot => slot.lastUpdated?.split('T')[0] === dateFilter);
    return filtered;
  };

  return (
    <div className="parking-slot-management">
      <HeaderPages title="Parking Slot Management" onBack={() => navigate('/dashboard')} />

      <div className="card">
        <SlotConfiguration
          locations={locations}
          slots={filterSlots()}
          selectedLocation={selectedLocation}
          dateFilter={dateFilter}
          timeFilter={timeFilter}
          onLocationChange={setSelectedLocation}
          onDateFilterChange={setDateFilter}
          onTimeFilterChange={setTimeFilter}
          onClearFilters={() => { setDateFilter(''); setTimeFilter(''); }}
          onEditSlot={handleEditSlot}
          onDeleteSlot={handleDeleteSlot}
          onAddSlot={() => setShowAddSlotModal(true)}
          onAddLocation={() => setShowAddLocationModal(true)}
        />
      </div>

      <div className="card">
        <ParkingLotManagement
          locations={locations}
          slots={slots}
          selectedLocation={selectedLocation}
          operationMode={operationMode}
          onOperationModeChange={setOperationMode}
          onSlotClick={handleSlotClick}
          onAddSlot={() => setShowAddSlotModal(true)}
        />
      </div>

      <div className="card">
        <SlotOperations
          selectedOperation={selectedOperation}
          slots={slots}
          onOperationChange={setSelectedOperation}
          selectedSlotForMaintenance={selectedSlotForMaintenance}
          onSlotForMaintenanceChange={setSelectedSlotForMaintenance}
          setSlots={setSlots}
        />
      </div>

      {showAddLocationModal && (
        <AddLocationModal
          onClose={() => setShowAddLocationModal(false)}
          onAddLocation={handleAddLocation}
          currentAdmin={loggedInAdmin}
        />
      )}

      {showAddSlotModal && (
        <AddSlotModal
          editingSlot={editingSlot}
          locations={locations}
          onClose={() => { setShowAddSlotModal(false); setEditingSlot(null); }}
          onAddSlot={handleAddSlot}
          adminId={loggedInAdmin.id}
        />
      )}
    </div>
  );
};

export default ParkingSlotManagement;
