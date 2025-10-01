import React from 'react';
import { CloseIcon } from '../../Icons/Icons';
import '../common/AuthCommon.css';

const PrivacyModal = ({ onClose }) => {
  return (
    <div className="auth-modal-overlay">
      <div className="auth-modal-content">
        <div className="auth-modal-header">
          <h2>Privacy Policy</h2>
          <button className="auth-modal-close" onClick={onClose}>
            <CloseIcon />
          </button>
        </div>
        <div className="auth-modal-body">
          <h3>1. Information We Collect</h3>
          <p>We collect information you provide directly to us, such as when you create an account, including your name, email address, and profile picture.</p>
          
          <h3>2. How We Use Your Information</h3>
          <p>We use the information we collect to provide, maintain, and improve our services, and to communicate with you about products, services, offers, and events.</p>
          
          <h3>3. Information Sharing</h3>
          <p>We do not sell your personal information. We may share information with vendors and service providers who need access to perform work on our behalf.</p>
          
          <h3>4. Data Security</h3>
          <p>We implement appropriate security measures to protect your personal information from unauthorized access.</p>
          
          <h3>5. Your Choices</h3>
          <p>You may update, correct, or delete information about you at any time by logging into your account.</p>
          
          <h3>6. Changes to This Policy</h3>
          <p>We may change this privacy policy from time to time. We will post any changes on this page.</p>
        </div>
        <div className="auth-modal-footer">
          <button className="auth-modal-agree-btn" onClick={onClose}>I Understand</button>
        </div>
      </div>
    </div>
  );
};

export default PrivacyModal;