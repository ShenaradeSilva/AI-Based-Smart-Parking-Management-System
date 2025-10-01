import React, { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { Logo1 } from '../../Logos/Logos';
import './Header.css';

const Header = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const navigate = useNavigate();
  const location = useLocation();

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  const handleSignUpClick = () => {
    setIsMenuOpen(false);
    navigate('/signup');
  };

  const handleSignInClick = () => {
    setIsMenuOpen(false);
    navigate('/signin');
  };

  const scrollToSection = (sectionId) => {
    setIsMenuOpen(false);
    
    if (window.location.pathname !== '/') {
      navigate('/');
      setTimeout(() => {
        const element = document.getElementById(sectionId);
        if (element) {
          element.scrollIntoView({ behavior: 'smooth' });
        }
      }, 100);
    } else {
      const element = document.getElementById(sectionId);
      if (element) {
        element.scrollIntoView({ behavior: 'smooth' });
      }
    }
  };

  return (
    <div className="header-container">
      <header className="header">
        <div className="logo-container">
          <Logo1 />
        </div>
        <div className={`mobile-menu-toggle ${isMenuOpen ? 'active' : ''}`} onClick={toggleMenu}>
          <span></span>
          <span></span>
          <span></span>
        </div>
        <div className={`header-right ${isMenuOpen ? 'active' : ''}`}>
          <div className="navbar-links">
            <Link to="/" onClick={() => setIsMenuOpen(false)}>Home</Link>
            <a href="#about" onClick={(e) => { e.preventDefault(); scrollToSection('about'); }}>About Us</a>
            <a href="#services" onClick={(e) => { e.preventDefault(); scrollToSection('services'); }}>Services</a>
            <a href="#contact" onClick={(e) => { e.preventDefault(); scrollToSection('contact'); }}>Contact Us</a>
          </div>

          {location.pathname === "/" && (
            <nav className="nav">
              <button className="nav-btn" onClick={handleSignInClick}>Sign In</button>
              <button className="nav-btn primary" onClick={handleSignUpClick}>Sign Up</button>
            </nav>
          )}
        </div>
      </header>
    </div>
  );
};

export default Header;