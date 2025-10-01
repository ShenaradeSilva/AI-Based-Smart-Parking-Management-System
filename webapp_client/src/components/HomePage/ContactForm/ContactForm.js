import React, { useState } from 'react';
import { validateName, validateEmail } from '../../../utils/validations';
import './ContactForm.css';
import API from '../../../api/axios';
import webappimg4 from '../../../assets/web_app_image4.jpg';

function ContactForm() {
  const [formData, setFormData] = useState({ name: '', email: '', message: '' });
  const [errors, setErrors] = useState({});
  const [isSubmitted, setIsSubmitted] = useState(false);

  const validateForm = () => {
    const newErrors = {};
    newErrors.name = validateName(formData.name);
    newErrors.email = validateEmail(formData.email);

    if (!formData.message.trim()) {
      newErrors.message = 'Message is required';
    } else if (formData.message.trim().length < 10) {
      newErrors.message = 'Message must be at least 10 characters long';
    }

    Object.keys(newErrors).forEach((key) => !newErrors[key] && delete newErrors[key]);
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    if (errors[name]) setErrors((prev) => ({ ...prev, [name]: '' }));
  };

  const handleBlur = (e) => {
    const { name, value } = e.target;
    if (name === 'name') setErrors((prev) => ({ ...prev, name: validateName(value) }));
    if (name === 'email') setErrors((prev) => ({ ...prev, email: validateEmail(value) }));
    if (name === 'message') {
      if (!value.trim()) setErrors((prev) => ({ ...prev, message: 'Message is required' }));
      else if (value.trim().length < 10) setErrors((prev) => ({ ...prev, message: 'Message must be at least 10 characters long' }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validateForm()) return;

    try {
      const response = await API.post('/api/contact/send', formData);
      if (response.data.status === 'success') {
        setIsSubmitted(true);
        setTimeout(() => {
          setFormData({ name: '', email: '', message: '' });
          setIsSubmitted(false);
        }, 3000);
      }
    } catch (error) {
      console.error('Error sending message:', error);
    }
  };

  return (
    <div className="contact-flex-container">
      {/* Contact Info */}
      <div className="contact-info">
        <h3>Get in Touch</h3>
        <p><strong>Email:</strong> parkflow.info@gmail.com</p>
        <p><strong>Hours:</strong> Monday-Friday: 9am-6pm</p>
        <div className="contact-image-large">
          <img src={webappimg4} alt="Contact" />
        </div>
      </div>

      {/* Contact Form */}
      <div className="contact-form-wrapper">
        {isSubmitted ? (
          <div className="success-message">
            <i className="fas fa-check-circle"></i>
            <p>Thank you for your message! We'll get back to you soon.</p>
          </div>
        ) : (
          <form className="contact-form" onSubmit={handleSubmit}>
            <div className="form-group">
              <input
                type="text"
                name="name"
                placeholder="Your Name"
                value={formData.name}
                onChange={handleChange}
                onBlur={handleBlur}
                className={errors.name ? 'error' : ''}
              />
              {errors.name && <span className="error-message">{errors.name}</span>}
            </div>

            <div className="form-group">
              <input
                type="email"
                name="email"
                placeholder="Your Email"
                value={formData.email}
                onChange={handleChange}
                onBlur={handleBlur}
                className={errors.email ? 'error' : ''}
              />
              {errors.email && <span className="error-message">{errors.email}</span>}
            </div>

            <div className="form-group">
              <textarea
                name="message"
                placeholder="Your Message"
                rows="4"
                value={formData.message}
                onChange={handleChange}
                onBlur={handleBlur}
                className={errors.message ? 'error' : ''}
              />
              {errors.message && <span className="error-message">{errors.message}</span>}
            </div>

            <button type="submit" className="nav-btn primary">Send Message</button>
          </form>
        )}
      </div>
    </div>
  );
}

export default ContactForm;
