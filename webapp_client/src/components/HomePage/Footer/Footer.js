import React from 'react';
import { Logo1 } from '../../Logos/Logos';
import './Footer.css';

const Footer = () => {
  return (
    <div className="footer-container">
      <footer className="footer">
        <div className="logo-container">
          <Logo1 />
        </div>
        <div className="footer-text">
          <p>&copy; 2025 Park Flow. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
};

export default Footer;