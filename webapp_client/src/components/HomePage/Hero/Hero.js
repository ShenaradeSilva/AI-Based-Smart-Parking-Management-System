import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import webappimg1 from "../../../assets/web_app_image1.jpg";
import webappimg2 from "../../../assets/web_app_image2.png";
import webappimg3 from "../../../assets/web_app_image3.png";
import './Hero.css';

const Hero = () => {
  const navigate = useNavigate();
  const images = [webappimg1, webappimg2, webappimg3];
  const [currentIndex, setCurrentIndex] = useState(0);

  // Auto-slide every 3 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentIndex((prevIndex) => (prevIndex + 1) % images.length);
    }, 3000);
    return () => clearInterval(interval);
  }, [images.length]);

  const handleSignIn = () => navigate('/signin');
  const handleSignUp = () => navigate('/signup');

  return (
    <div className="hero-card">
      <div className='hero-header'>
        <div className='hero-text'>
          <h1>Park Flow</h1>
          <p>Manage parkings with our seamless parking solution</p>
        </div>
      </div>

      <div className="image-frame">
        <img src={images[currentIndex]} alt={`Slide ${currentIndex + 1}`} />
      </div>

      <nav className="nav center-buttons">
        <button className="nav-btn" onClick={handleSignIn}>Sign In</button>
        <button className="nav-btn primary" onClick={handleSignUp}>Sign Up</button>
      </nav>
    </div>
  );
};

export default Hero;
