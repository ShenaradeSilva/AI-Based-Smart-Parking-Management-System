import React from 'react';
import { CloseIcon } from '../../Icons/Icons';
import '../common/AuthCommon.css';

const TermsModal = ({ onClose }) => {
  return (
    <div className="auth-modal-overlay">
      <div className="auth-modal-content">
        <div className="auth-modal-header">
          <h2>Terms and Conditions</h2>
          <button className="auth-modal-close" onClick={onClose}>
            <CloseIcon />
          </button>
        </div>
        <div className="auth-modal-body">
          <h3>1. Acceptance of Terms</h3>
          <p>By accessing or using our services, you agree to be bound by these Terms and Conditions.</p>
          
          <h3>2. User Accounts</h3>
          <p>You are responsible for maintaining the confidentiality of your account and password.</p>
          
          <h3>3. User Conduct</h3>
          <p>You agree not to use the service for any unlawful purpose or in any way that might harm, damage, or disparage any other party.</p>
          
          <h3>4. Intellectual Property</h3>
          <p>All content included on this site, such as text, graphics, logos, is the property of our company.</p>
          
          <h3>5. Termination</h3>
          <p>We may terminate or suspend your account immediately, without prior notice, for any reason whatsoever.</p>
          
          <h3>6. Changes to Terms</h3>
          <p>We reserve the right to modify these terms at any time. We will provide notice of significant changes.</p>
        </div>
        <div className="auth-modal-footer">
          <button className="auth-modal-agree-btn" onClick={onClose}>I Understand</button>
        </div>
      </div>
    </div>
  );
};

export default TermsModal;