import React, { useEffect, useState } from "react";
import { CloseIcon } from "../../../Icons/Icons";
import API from "../../../../api/axios";
import vehiclesData from "../../../../data/vehiclesData";
import "./Modals.css";

const RegisteredVehiclesModal = ({ onClose }) => {
  const [vehicles, setVehicles] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchVehicles = async () => {
      try {
        const res = await API.get("/api/vehicles"); // backend endpoint
        setVehicles(res.data);
      } catch (err) {
        console.error("Failed to fetch vehicles, using mock data", err);
        setVehicles(vehiclesData); // fallback to mock
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
                    <td>{v.user?.name || v.owner || "N/A"}</td>
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
