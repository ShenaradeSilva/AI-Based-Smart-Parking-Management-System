import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import VehicleList from './components/VehicleList/VehicleList';
import VehicleModal from './components/VehicleModal/VehicleModal';
import VehicleReportModal from './components/VehicleReportModal/VehicleReportModal';
import vehiclesData from '../../data/vehiclesData'; // Mock data
import { validateImageFile } from '../../utils/validations';
import './VehicleManagement.css';
import HeaderPages from '../Common/HeaderPages';
import Tesseract from 'tesseract.js';
import API from '../../api/axios';

const VehicleManagement = () => {
    const navigate = useNavigate();
    const [vehicles, setVehicles] = useState([]);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [selectedVehicle, setSelectedVehicle] = useState(null);
    const [isEditing, setIsEditing] = useState(false);
    const [showReportModal, setShowReportModal] = useState(false);

    const vehicleTypes = ['Car', 'Van', 'Truck', 'Motorcycle'];

    const handleBackToDashboard = () => navigate('/dashboard');

    const formatDate = (date) =>
        new Date(date).toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' });

    // Fetch vehicles from backend and merge with mock data
    const fetchVehicles = async () => {
        try {
            const response = await API.get('/api/vehicles');
            const formattedBackend = response.data.map(v => ({
                vehicle_id: v.vehicle_id,
                plateNumber: v.plate_number,
                type: v.type,
                owner: v.owner || 'N/A',
                registeredDate: formatDate(v.created_at)
            }));

            const formattedMock = vehiclesData.map(v => ({
                vehicle_id: v.vehicle_id,
                plateNumber: v.plateNumber,
                type: v.type,
                owner: v.owner,
                registeredDate: formatDate(v.registeredDate)
            }));

            const merged = [
                ...formattedMock,
                ...formattedBackend.filter(b => !formattedMock.some(m => m.plateNumber === b.plateNumber))
            ];
            setVehicles(merged);
        } catch (error) {
            console.error('Error fetching vehicles:', error);
            const formattedMock = vehiclesData.map(vehicle => ({
                ...vehicle,
                registeredDate: formatDate(vehicle.registeredDate)
            }));
            setVehicles(formattedMock);
        }
    };

    useEffect(() => { fetchVehicles(); }, []);

    // Register new vehicle
    const handleRegisterVehicle = async (vehicleData) => {
        try {
            let userResponse;
            if (vehicleData.owner) {
                userResponse = await API.post('/api/users', { name: vehicleData.owner });
            }
            const userId = userResponse?.data?.user_id || null;

            const payload = {
                user_id: userId,
                plate_number: vehicleData.plateNumber,
                type: vehicleData.type
            };

            const response = await API.post('/api/vehicles', payload);
            setVehicles(prev => [...prev, {
                vehicle_id: response.data.vehicle_id,
                plateNumber: response.data.plate_number,
                type: response.data.type,
                owner: vehicleData.owner,
                registeredDate: formatDate(response.data.created_at)
            }]);
            setIsModalOpen(false);
        } catch (error) {
            console.error('Error registering vehicle:', error);
            alert('Failed to register vehicle.');
        }
    };

    // Edit existing vehicle
    const handleEditVehicle = async (vehicleData) => {
        try {
            const payload = {
                plate_number: vehicleData.plateNumber,
                type: vehicleData.type
            };
            const response = await API.put(`/api/vehicles/${vehicleData.vehicle_id}`, payload);

            setVehicles(prev => prev.map(v =>
                v.vehicle_id === response.data.vehicle_id
                    ? { ...v, plateNumber: response.data.plate_number, type: response.data.type }
                    : v
            ));
            setSelectedVehicle(null);
            setIsEditing(false);
        } catch (error) {
            console.error('Error updating vehicle:', error);
            alert('Failed to update vehicle.');
        }
    };

    // Delete vehicle
    const handleDeleteVehicle = async (id) => {
        try {
            await API.delete(`/api/vehicles/${id}`);
            setVehicles(prev => prev.filter(v => v.vehicle_id !== id));
        } catch (error) {
            console.error('Error deleting vehicle:', error);
            alert('Failed to delete vehicle.');
        }
    };

    // ANPR upload and detection
    const handleANPRUpload = (e) => {
        const file = e.target.files[0];
        if (!file) return;

        const error = validateImageFile(file);
        if (error) {
            alert(error);
            e.target.value = '';
            return;
        }

        Tesseract.recognize(file, 'eng', { logger: m => console.log(m) })
            .then(({ data: { text } }) => {
                const cleanedText = text.replace(/\s/g, '').toUpperCase();
                const plateMatch = cleanedText.match(/[A-Z]{3}-?\d{4}/);

                if (!plateMatch) {
                    alert('Failed to detect a valid plate number.');
                    return;
                }

                let detectedPlate = plateMatch[0];
                if (!detectedPlate.includes('-')) {
                    detectedPlate = detectedPlate.slice(0, 3) + '-' + detectedPlate.slice(3);
                }

                setSelectedVehicle({
                    plateNumber: detectedPlate,
                    type: '',
                    owner: '',
                });

                setIsEditing(false);
                setIsModalOpen(true);
            })
            .catch(err => alert('Failed to detect plate number: ' + err));

        e.target.value = '';
    };

    // Export CSV using backend endpoint
    const exportCSV = async () => {
        try {
            const response = await API.get('/api/vehicles/export-csv', { responseType: 'blob' });
            const url = window.URL.createObjectURL(new Blob([response.data]));
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', 'vehicles.csv');
            document.body.appendChild(link);
            link.click();
            link.remove();
        } catch (err) {
            alert('Failed to export CSV: ' + err.message);
        }
    };

    const handleEditClick = (vehicle) => {
        setSelectedVehicle(vehicle);
        setIsEditing(true);
        setIsModalOpen(true);
    };

    return (
        <div className="vehicle-management-page">
            <HeaderPages title="Manage Vehicles" onBack={handleBackToDashboard} />

            <div className="vehicle-management-content">
                <div className="vehicle-actions-card card">
                    <div className="vehicle-actions">
                        <button className="btn btn-primary" onClick={() => { setSelectedVehicle(null); setIsEditing(false); setIsModalOpen(true); }}>
                            Register Vehicle
                        </button>

                        <label htmlFor="anpr-upload" className="btn btn-secondary">
                            ANPR Scan
                            <input id="anpr-upload" type="file" accept=".jpg,.jpeg,.png,.gif" onChange={handleANPRUpload} />
                        </label>

                        <button className="btn btn-tertiary" onClick={() => setShowReportModal(true)}>
                            Load Report
                        </button>
                    </div>
                </div>

                <div className="vehicle-list-card card">
                    <VehicleList vehicles={vehicles} onEdit={handleEditClick} onDelete={handleDeleteVehicle} />
                </div>

                {(isModalOpen || selectedVehicle) && (
                    <VehicleModal
                        vehicle={selectedVehicle}
                        vehicleTypes={vehicleTypes}
                        onClose={() => { setIsModalOpen(false); setSelectedVehicle(null); }}
                        onSave={isEditing ? handleEditVehicle : handleRegisterVehicle}
                        isEditing={isEditing}
                    />
                )}

                {showReportModal && (
                    <VehicleReportModal
                        vehicles={vehicles}
                        onClose={() => setShowReportModal(false)}
                        onExport={exportCSV}
                    />
                )}
            </div>
        </div>
    );
};

export default VehicleManagement;
