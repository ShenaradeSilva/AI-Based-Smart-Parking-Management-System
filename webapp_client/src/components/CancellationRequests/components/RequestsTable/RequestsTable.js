import React from 'react';
import { ApproveIcon, RejectIcon } from '../../../Icons/Icons';
import './RequestsTable.css';

const RequestsTable = ({ requests, onApprove, onReject }) => {
  return (
    <table className="requests-table">
      <thead>
        <tr>
          <th>Request ID</th>
          <th>Driver Name</th>
          <th>Vehicle Number</th>
          <th>Slot</th>
          <th>Cancellation Reason</th>
          <th>Requested Time</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        {requests.map(r => (
          <tr key={r.id}>
            <td>{r.id}</td>
            <td>{r.driver_name}</td>
            <td>{r.vehicle_number}</td>
            <td>{r.slot}</td>
            <td>{r.reason}</td>
            <td>{new Date(r.requested_at).toLocaleString()}</td>
            <td className="actions-cell">
              <button className="approve-btn" onClick={() => onApprove(r.id)}>
                <ApproveIcon /> Approve
              </button>
              <button className="reject-btn" onClick={() => onReject(r.id)}>
                <RejectIcon /> Reject
              </button>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
};

export default RequestsTable;
