import React, { useState } from 'react';
import { validateEmail, clearError } from '../../../../utils/validations';

const EmailStep = ({ email, setEmail, isLoading, onSubmit }) => {
  const [errors, setErrors] = useState({});
  const [touched, setTouched] = useState({});

  const handleBlur = (field) => {
    setTouched(prev => ({ ...prev, [field]: true }));
    
    // Validate email on blur using shared validation function
    if (field === 'email') {
      const error = validateEmail(email);
      setErrors(prev => ({ ...prev, email: error }));
    }
  };

  const handleChange = (e) => {
    const value = e.target.value;
    setEmail(value);
    
    // Clear error when user starts typing using utility function
    if (errors.email && touched.email) {
      setErrors(clearError(errors, 'email'));
    }
  };

  const handleSubmit = () => {
    // Validate before submitting using shared validation function
    const emailError = validateEmail(email);
    
    if (emailError) {
      setErrors({ email: emailError });
      setTouched({ email: true });
      return;
    }
    
    // If validation passes, call the onSubmit function
    onSubmit();
  };

  const handleKeyPress = (e) => {
    // Allow submitting with Enter key
    if (e.key === 'Enter') {
      e.preventDefault();
      handleSubmit();
    }
  };

  return (
    <div className="reset-step">
      <h3>Forgot your password?</h3>
      <p className="instruction-text">Enter your email address and we'll send you a verification code</p>
      
      <div className="auth-form-group">
        <label htmlFor="email">Email Address</label>
        <input
          type="email"
          id="email"
          placeholder="Enter your email"
          value={email}
          onChange={handleChange}
          onBlur={() => handleBlur('email')}
          onKeyPress={handleKeyPress}
          className={`auth-form-input ${touched.email && errors.email ? 'error' : ''}`}
          autoComplete="email"
          autoFocus
        />
        {touched.email && errors.email && (
          <span className="error-message">{errors.email}</span>
        )}
      </div>

      <div className="auth-btn-container">
        <button 
          onClick={handleSubmit} 
          className={`auth-btn ${isLoading ? 'loading' : ''}`}
          disabled={isLoading || (touched.email && !!errors.email)}
        >
          {isLoading ? "Sending Code..." : "Send Verification Code"}
        </button>
      </div>

      <p className="auth-link">
        Remember your password? <a href="/signin">Sign In</a>
      </p>
    </div>
  );
};

export default EmailStep;