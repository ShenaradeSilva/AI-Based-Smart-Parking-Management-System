import React, { useEffect, useState } from "react";
import { CloseIcon } from "../../../Icons/Icons";
import API from "../../../../api/axios";
import "./Modals.css";

const RegisteredVehiclesModal = ({ onClose }) => {
  const [vehicles, setVehicles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchVehicles = async () => {
      try {
        const res = await API.get("/api/vehicles/list"); // backend endpoint
        setVehicles(res.data); // only use backend data
      } catch (err) {
        console.error("Failed to fetch vehicles from backend", err);
        setError("Failed to load vehicles. Please try again.");
      } finally {
        setLoading(false);
      }
    };

    fetchVehicles();
  }, []);

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h2>Registered Vehicles ({vehicles.length})</h2>
          <button className="close-button" onClick={onClose}>
            <CloseIcon />
          </button>
        </div>
        <div className="modal-body">
          {loading ? (
            <p>Loading vehicles...</p>
          ) : error ? (
            <p className="error">{error}</p>
          ) : vehicles.length === 0 ? (
            <p>No registered vehicles found.</p>
          ) : (
            <table className="drivers-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Plate Number</th>
                  <th>Vehicle Type</th>
                  <th>Owner</th>
                  <th>Registered Date</th>
                </tr>
              </thead>
              <tbody>
                {vehicles.map((v) => (
                  <tr key={v.vehicle_id || v.id}>
                    <td>{v.vehicle_id || v.id}</td>
                    <td>{v.plate_number || v.plateNumber}</td>
                    <td>{v.type}</td>
                    <td>{v.owner}</td>
                    <td>{v.created_at?.split("T")[0] || v.registeredDate}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
};

export default RegisteredVehiclesModal;
