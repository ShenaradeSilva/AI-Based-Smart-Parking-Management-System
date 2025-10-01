import React from 'react';
import './VehicleList.css';
import { DeleteIcon, EditIcon } from '../../../Icons/Icons';

const VehicleList = ({ vehicles, onEdit, onDelete }) => {
  return (
    <div className="vehicle-list">
      <h3>Registered Vehicles ({vehicles.length})</h3>
      <div className="vehicle-cards">
        {vehicles.map(vehicle => (
          <div key={vehicle.vehicle_id} className="vehicle-card">
            <div className="vehicle-card-header">
              <h4>{vehicle.plateNumber}</h4>
            </div>
            <div className="vehicle-details">
              <p>{vehicle.type}</p>
              <p>Owner: {vehicle.owner}</p>
              <p className="registered-date">Registered: {vehicle.registeredDate}</p>
            </div>
            <div className="vehicle-actions">
              <button className="btn btn-icon" onClick={() => onEdit(vehicle)}>
                <EditIcon /> Edit
              </button>
              <button className="btn btn-icon btn-danger" onClick={() => onDelete(vehicle.vehicle_id)}>
                <DeleteIcon /> Delete
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default VehicleList;
