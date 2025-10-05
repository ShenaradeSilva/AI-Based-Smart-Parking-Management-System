import React, { useState, useEffect } from 'react';
import { useNavigate, Routes, Route } from 'react-router-dom';
import VehicleManagement from '../VehicleManagement/VehicleManagement';
import './Bookings.css';
import FiltersSection from './components/FiltersSection/FiltersSection';
import BookingsList from './components/BookingsList/BookingsList';
import BookingModal from './components/BookingModal/BookingModal';
import CreateBookingModal from './components/CreateBookingModal/CreateBookingModal';
import HeaderPages from '../Common/HeaderPages';
import { bookings as generateBookings } from '../../data/bookings'; // mock bookings
import vehiclesData from '../../data/vehiclesData'; // mock vehicles
import API from '../../api/axios'; // Axios instance for backend

const USE_BACKEND = true; // Toggle backend integration
const HOURLY_RATE = 150; // LKR/hour

const Bookings = () => {
  const navigate = useNavigate();
  const [bookings, setBookings] = useState([]);
  const [filteredBookings, setFilteredBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState({ date: '', time: '', location: '', status: 'all' });
  const [selectedBooking, setSelectedBooking] = useState(null);
  const [showBookingModal, setShowBookingModal] = useState(false);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [locations, setLocations] = useState([]);
  const [vehicles, setVehicles] = useState(vehiclesData);

  // --- Helper function (renamed from useMockData) ---
  const loadMockData = () => {
    const data = generateBookings();
    setBookings(data);
    setFilteredBookings(data);
    setLocations([...new Set(data.map(b => b.location))]);
    setVehicles(vehiclesData);
    setLoading(false);
  };

  // --- Fetch data (backend or mock) ---
  useEffect(() => {
    const fetchData = async () => {
      if (USE_BACKEND) {
        try {
          const [resBookings, resVehicles] = await Promise.all([
            API.get('/reservations'),
            API.get('/vehicles'),
          ]);

          const mappedBookings = resBookings.data.map(b => ({
            id: b.reservation_id,
            location: b.parking_slot?.location_name || `Location ${b.parking_slot_id}`,
            slot: b.parking_slot?.slot_number || b.parking_slot_id,
            date: b.date,
            time: b.start_time,
            duration: b.duration || 1,
            status: b.status,
            vehicle: b.vehicle?.plate_number || 'N/A',
            amount: b.amount || HOURLY_RATE * (b.duration || 1),
            paymentMethod: b.payment_method || 'Cash',
            paymentStatus: b.payment_status || 'Pending',
            bookingReference: `REF${b.reservation_id}`,
          }));

          setBookings(mappedBookings);
          setFilteredBookings(mappedBookings);
          setLocations([...new Set(mappedBookings.map(b => b.location))]);

          setVehicles(resVehicles.data.length ? resVehicles.data : vehiclesData);
        } catch (err) {
          console.error('Error fetching backend data:', err);
          loadMockData(); // ✅ renamed function
        } finally {
          setLoading(false);
        }
      } else {
        loadMockData();
      }
    };

    fetchData();
  }, []);

  // --- Filter bookings ---
  useEffect(() => {
    filterBookings();
  }, [filters, bookings]);

  const filterBookings = () => {
    let result = bookings;
    if (filters.date) result = result.filter(b => b.date === filters.date);
    if (filters.time) result = result.filter(b => filters.time === 'all' ? true : b.time.includes(filters.time));
    if (filters.location) result = result.filter(b => b.location === filters.location);
    if (filters.status !== 'all') result = result.filter(b => b.status === filters.status);
    setFilteredBookings(result);
  };

  const handleFilterChange = (e) => {
    const { name, value } = e.target;
    setFilters(prev => ({ ...prev, [name]: value }));
  };

  const clearFilters = () => setFilters({ date: '', time: '', location: '', status: 'all' });

  const handleViewDetails = (booking) => {
    setSelectedBooking(booking);
    setShowBookingModal(true);
  };

  const handleCancelBooking = async (id) => {
    if (!window.confirm('Are you sure you want to cancel this reservation?')) return;

    if (USE_BACKEND) {
      try {
        await API.delete(`/api/reservations/${id}`);
        setBookings(prev => prev.filter(b => b.id !== id));
      } catch (err) {
        console.error('Failed to cancel booking:', err);
        alert('Failed to cancel reservation on backend.');
      }
    } else {
      setBookings(prev => prev.filter(b => b.id !== id));
    }
  };

  const handleBackToDashboard = () => navigate('/dashboard');
  const handleCreateBooking = () => setShowCreateModal(true);

  // --- Booked slots per location ---
  const bookedSlots = {};
  bookings.forEach(b => {
    if (!bookedSlots[b.location]) bookedSlots[b.location] = [];
    bookedSlots[b.location].push(b.slot);
  });

  const handleSaveBooking = async (newBooking) => {
    const durationNum = Number(newBooking.duration) || 0;
    newBooking.amount = durationNum * HOURLY_RATE;

    if (USE_BACKEND) {
      try {
        const res = await API.post('/reservations', {
          date: newBooking.date,
          start_time: newBooking.time,
          end_time: newBooking.time, // adjust if needed
          parking_slot_id: newBooking.slot.replace('Slot ', ''),
          vehicle_id: vehicles.find(v => v.plateNumber === newBooking.vehicle)?.id,
          status: 'Upcoming',
          duration: durationNum,
          amount: newBooking.amount,
          payment_method: newBooking.paymentMethod,
        });

        const b = res.data;
        setBookings(prev => [...prev, {
          id: b.reservation_id,
          location: newBooking.location,
          slot: newBooking.slot,
          date: b.date,
          time: b.start_time,
          duration: b.duration || 1,
          status: b.status,
          vehicle: newBooking.vehicle,
          amount: b.amount || newBooking.amount,
          paymentMethod: b.payment_method || 'Cash',
          paymentStatus: b.payment_status || 'Pending',
          bookingReference: `REF${b.reservation_id}`,
        }]);
        setShowCreateModal(false);
      } catch (err) {
        console.error('Failed to create reservation:', err);
      }
    } else {
      const bookingWithId = { ...newBooking, id: bookings.length + 1 };
      setBookings(prev => [...prev, bookingWithId]);
      setShowCreateModal(false);
    }
  };

  if (loading) return <div className="bookings-loading">Loading reservations...</div>;

  return (
    <div className="bookings-container">
      <Routes>
        <Route
          path="/"
          element={
            <>
              <HeaderPages
                title="Reservations"
                filteredBookings={filteredBookings}
                onBack={handleBackToDashboard}
              />

              <FiltersSection
                filters={filters}
                locations={locations}
                onFilterChange={handleFilterChange}
                onClearFilters={clearFilters}
                onCreateBooking={handleCreateBooking}
              />

              <BookingsList
                bookings={filteredBookings}
                onViewDetails={handleViewDetails}
                onCancel={handleCancelBooking}
              />

              {showBookingModal && selectedBooking && (
                <BookingModal booking={selectedBooking} onClose={() => setShowBookingModal(false)} />
              )}

              {showCreateModal && (
                <CreateBookingModal
                  vehicles={vehicles}
                  locations={locations}
                  bookedSlots={bookedSlots}
                  onClose={() => setShowCreateModal(false)}
                  onSave={handleSaveBooking}
                />
              )}
            </>
          }
        />
        <Route path="vehicle-management" element={<VehicleManagement />} />
      </Routes>
    </div>
  );
};

export default Bookings;
