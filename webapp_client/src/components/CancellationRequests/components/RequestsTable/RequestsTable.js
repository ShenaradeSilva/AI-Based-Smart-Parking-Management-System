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
        {requests.map(request => (
          <tr key={request.id}>
            <td>{request.id}</td>
            <td>{request.driverName}</td>
            <td>{request.vehicleNumber}</td>
            <td>{request.slot}</td>
            <td>{request.reason}</td>
            <td>{request.requestedTime}</td>
            <td className="actions-cell">
              <button 
                className="approve-btn"
                onClick={() => onApprove(request.id)}
              >
                <ApproveIcon /> Approve
              </button>
              <button 
                className="reject-btn"
                onClick={() => onReject(request.id)}
              >
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