import React from 'react';
import { EditIcon, ApproveIcon, RejectIcon } from '../../../Icons/Icons';
import './ActionButtons.css';

const ActionButtons = ({ isEditing, onEdit, onCancel, onSave, isSaveDisabled }) => {
  return (
    <div className="action-buttons">
      {isEditing ? (
        <>
          <button className="cancel-btn" onClick={onCancel}>
            <RejectIcon /> Cancel
          </button>
          <button 
            className="save-btn" 
            onClick={onSave}
            disabled={isSaveDisabled}
          >
            <ApproveIcon /> Save Info
          </button>
        </>
      ) : (
        <button className="edit-btn" onClick={onEdit}>
          <EditIcon /> Edit Info
        </button>
      )}
    </div>
  );
};

export default ActionButtons;