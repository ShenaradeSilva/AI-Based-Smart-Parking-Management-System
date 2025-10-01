import React from 'react';
import { passwordRequirements } from '../../../utils/validations';
import { ApproveIcon } from '../../Icons/Icons';

const PasswordRequirementsDisplay = ({ password, isVisible }) => {
  if (!isVisible || !password || password.length === 0) {
    return null;
  }

  return (
    <div className="password-requirements">
      {passwordRequirements.map((req) => {
        const satisfied = req.test(password);
        return (
          <div key={req.id} className={`requirement-item ${satisfied ? 'satisfied' : ''}`}>
            {satisfied ? <ApproveIcon /> : ''} {req.label}
          </div>
        );
      })}
    </div>
  );
};

export default PasswordRequirementsDisplay;