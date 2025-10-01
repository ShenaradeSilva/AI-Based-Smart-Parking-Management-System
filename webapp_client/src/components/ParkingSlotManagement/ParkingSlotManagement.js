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
import locationsData from '../../data/locations';
import slotsData from '../../data/slots';

const ParkingSlotManagement = () => {
  const navigate = useNavigate();

  const [locations, setLocations] = useState(locationsData);
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

  // Get logged-in admin from localStorage (replace with context if you have auth context)
  const loggedInAdmin = {
    id: localStorage.getItem('admin_id') || 1, // fallback to 1 if not found
    name: localStorage.getItem('admin_name') || 'Admin',
  };

  const normalizeSlots = (rawSlots, allLocations) =>
    rawSlots.map(slot => {
      const loc = allLocations.find(l => l.location_id === slot.parking_lot_id);
      return {
        ...slot,
        id: slot.id || slot.slot_id, // Ensure we store backend ID
        location: loc ? loc.name : 'Unknown',
        status: slot.status || 'Available',
        lastUpdated: slot.updated_at || slot.lastUpdated || new Date().toISOString(),
      };
    });

  const fetchData = async () => {
    try {
      const [locationsRes, slotsRes] = await Promise.all([
        API.get('/api/parking/locations'),
        API.get('/api/parking/slots'),
      ]);

      const mergedLocations = [
        ...locationsData,
        ...locationsRes.data.filter(loc => !locationsData.find(l => l.location_id === loc.location_id)),
      ];

      const mergedSlots = normalizeSlots([...slotsData, ...slotsRes.data], mergedLocations);

      setLocations(mergedLocations);
      setSlots(mergedSlots);
    } catch (err) {
      console.error('Error fetching data from backend', err);
      setSlots(normalizeSlots(slotsData, locationsData));
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleAddSlot = async (newSlotData) => {
    if (editingSlot) {
      // UI update first
      setSlots(slots.map(slot => slot.id === editingSlot.id ? { ...slot, ...newSlotData } : slot));

      try {
        await API.put(`/api/parking/slots/${editingSlot.id}`, {
          ...newSlotData,
          admin_id: loggedInAdmin.id,
          status: newSlotData.status.toLowerCase(),
        });
      } catch (err) {
        console.error('Error updating slot on backend', err);
      }

      setEditingSlot(null);
    } else {
      try {
        const res = await API.post('/api/parking/slots', {
          slot_number: newSlotData.slotNumber,
          parking_lot_id: locations.find(l => l.name === newSlotData.location)?.location_id,
          slot_type: 'standard',
          status: newSlotData.status.toLowerCase(),
          admin_id: loggedInAdmin.id,
        });

        // Use backend response ID
        const createdSlot = {
          ...newSlotData,
          id: res.data.id,
          lastUpdated: new Date().toISOString(),
        };
        setSlots([...slots, createdSlot]);
      } catch (err) {
        console.error('Error adding slot to backend', err);
      }
    }
    setShowAddSlotModal(false);
  };

  const handleDeleteSlot = async (slotId) => {
    if (!window.confirm('Are you sure you want to delete this slot?')) return;
    try {
      await API.delete(`/api/parking/slots/${slotId}`, { params: { admin_id: loggedInAdmin.id } });
      setSlots(slots.filter(slot => slot.id !== slotId));
    } catch (err) {
      console.error('Error deleting slot on backend', err);
    }
  };

  const handleEditSlot = (slot) => {
    setEditingSlot(slot);
    setShowAddSlotModal(true);
    setOperationMode(null);
  };

  const handleStatusChange = async (slotId, newStatus) => {
    setSlots(slots.map(slot => slot.id === slotId ? { ...slot, status: newStatus } : slot));
    try {
      await API.put(`/api/parking/slots/${slotId}/status`, null, {
        params: { status: newStatus.toLowerCase(), admin_id: loggedInAdmin.id },
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

  const handleAddLocation = async (loc) => {
    // Optimistic UI update
    const tempLoc = { ...loc, location_id: Date.now() };
    setLocations(prev => [...prev, tempLoc]);

    try {
      const res = await API.post('/api/parking/locations', { ...loc, admin_id: loggedInAdmin.id });
      // Replace temporary location with real backend ID
      setLocations(prev => prev.map(l => (l.location_id === tempLoc.location_id ? { ...l, location_id: res.data.id } : l)));
    } catch (err) {
      console.error('Error adding location to backend', err);
      // Rollback if backend fails
      setLocations(prev => prev.filter(l => l.location_id !== tempLoc.location_id));
    }
  };

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
          currentAdmin={loggedInAdmin} // Pass admin info
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
