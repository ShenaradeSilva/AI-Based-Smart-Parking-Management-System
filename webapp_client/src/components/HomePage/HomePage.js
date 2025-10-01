import React from 'react';
import Header from './Header/Header';
import Footer from './Footer/Footer';
import Hero from './Hero/Hero';
import ContactForm from './ContactForm/ContactForm';
import './HomePage.css';

function HomePage() {
  return (
    <div className="home-page">
      <Header />

      <main className="main">
        <div className="content-wrapper">
          <Hero />

          <section id="about" className="section-card">
            <h2>About Us</h2>
            <p>
              Park Flow is a startup parking management solution designed to streamline parking
              operations for businesses and provide seamless experiences for drivers.
              It is also designed so that parking station admins can manage and perform
              admin operations on parking reservations.
            </p>
          </section>

          <section id="services" className="section-card">
            <h2>Our Services</h2>
            <div className="services-grid">
              <div className="service-item">
                <h3>Smart Parking Management</h3>
                <p>Real-time monitoring and management of parking spaces with our advanced software platform.</p>
              </div>
              <div className="service-item">
                <h3>Reservation System</h3>
                <p>Allow customers to reserve parking spots in advance through our mobile app or website.</p>
              </div>
              <div className="service-item">
                <h3>Payment Processing</h3>
                <p>Secure and convenient payment solutions with multiple options for customers.</p>
              </div>
              <div className="service-item">
                <h3>Analytics & Reporting</h3>
                <p>Gain insights into parking usage patterns and optimize your facility operations.</p>
              </div>
            </div>
          </section>

          <section id="contact" className="section-card">
            <h2>Contact Us</h2>
            <ContactForm />
          </section>
        </div>
      </main>

      <Footer />
    </div>
  );
}

export default HomePage;
