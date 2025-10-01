import React, { useState, useEffect } from 'react';
import { validateVerificationCode, clearError } from '../../../../utils/validations';

const CodeStep = ({ email, code, setCode, isLoading, onSubmit, onResend }) => {
  const [errors, setErrors] = useState({});
  const [touched, setTouched] = useState({});

  useEffect(() => {
    // Validate code whenever it changes after user interaction
    if (touched.code) {
      const error = validateVerificationCode(code);
      setErrors(prev => ({ ...prev, code: error }));
    }
  }, [code, touched]);

  const handleBlur = (field) => {
    setTouched(prev => ({ ...prev, [field]: true }));
    
    // Validate code on blur using shared validation function
    if (field === 'code') {
      const error = validateVerificationCode(code);
      setErrors(prev => ({ ...prev, code: error }));
    }
  };

  const handleChange = (e) => {
    const value = e.target.value.replace(/\D/, '').slice(0, 4);
    setCode(value);
    
    // Clear error when user starts typing using utility function
    if (errors.code && touched.code) {
      setErrors(clearError(errors, 'code'));
    }
  };

  const handleSubmit = () => {
    // Validate before submitting using shared validation function
    const codeError = validateVerificationCode(code);
    
    if (codeError) {
      setErrors({ code: codeError });
      setTouched({ code: true });
      return;
    }
    
    // If validation passes, call the onSubmit function
    onSubmit();
  };

  const handleResend = (e) => {
    e.preventDefault();
    onResend();
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
      <h3>Check your email</h3>
      <p className="instruction-text">We've sent a 4-digit code to {email}</p>
      
      <div className="auth-form-group">
        <label htmlFor="code">Verification Code</label>
        <input
          type="text"
          id="code"
          inputMode="numeric"
          pattern="[0-9]*"
          maxLength="4"
          placeholder="Enter 4-digit code"
          value={code}
          onChange={handleChange}
          onBlur={() => handleBlur('code')}
          onKeyPress={handleKeyPress}
          className={`auth-form-input code-input ${touched.code && errors.code ? 'error' : ''}`}
          autoComplete="one-time-code"
          autoFocus
        />
        {touched.code && errors.code && (
          <span className="error-message">{errors.code}</span>
        )}
      </div>

      <p className="resend-text">
        Didn't receive the code? <a href="#" onClick={handleResend}>Resend code</a>
      </p>

      <div className="auth-btn-container">
        <button 
          onClick={handleSubmit} 
          className={`auth-btn ${isLoading ? 'loading' : ''}`}
          disabled={isLoading || (touched.code && !!errors.code)}
        >
          {isLoading ? "Verifying..." : "Verify Code"}
        </button>
      </div>
    </div>
  );
};

export default CodeStep;