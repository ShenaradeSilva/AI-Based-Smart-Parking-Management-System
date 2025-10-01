import React, { useState, useEffect } from 'react';
import { validatePassword, validateConfirmPassword, clearError } from '../../../../utils/validations';
import PasswordRequirementsDisplay from '../../common/PasswordRequirementsDisplay';
import { EyeIcon, EyeOffIcon } from '../../../Icons/Icons';

const PasswordStep = ({ newPassword, setNewPassword, confirmPassword, setConfirmPassword, isLoading, onSubmit }) => {
  const [errors, setErrors] = useState({});
  const [touched, setTouched] = useState({});
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isPasswordFocused, setIsPasswordFocused] = useState(false);

  useEffect(() => {
    // Validate passwords whenever they change after user interaction
    if (touched.newPassword) {
      const validationError = validatePassword(newPassword);
      setErrors(prev => ({ ...prev, newPassword: validationError }));
    }
    
    if (touched.confirmPassword) {
      const validationError = validateConfirmPassword(newPassword, confirmPassword);
      setErrors(prev => ({ ...prev, confirmPassword: validationError }));
    }
  }, [newPassword, confirmPassword, touched]);

  const handleBlur = (field) => {
    setTouched(prev => ({ ...prev, [field]: true }));
    
    let validationError = '';
    if (field === 'newPassword') {
      validationError = validatePassword(newPassword);
    } else if (field === 'confirmPassword') {
      validationError = validateConfirmPassword(newPassword, confirmPassword);
    }
    
    setErrors(prev => ({ ...prev, [field]: validationError }));
  };

  const handlePasswordChange = (e) => {
    const value = e.target.value;
    setNewPassword(value);
    
    // Clear error when user starts typing
    if (errors.newPassword && touched.newPassword) {
      setErrors(clearError(errors, 'newPassword'));
    }
    
    // Also validate confirm password if it exists
    if (confirmPassword && touched.confirmPassword) {
      const confirmError = validateConfirmPassword(value, confirmPassword);
      setErrors(prev => ({ ...prev, confirmPassword: confirmError }));
    }
  };

  const handleConfirmPasswordChange = (e) => {
    const value = e.target.value;
    setConfirmPassword(value);
    
    // Clear error when user starts typing
    if (errors.confirmPassword && touched.confirmPassword) {
      setErrors(clearError(errors, 'confirmPassword'));
    }
  };

  const handleSubmit = () => {
    const newTouched = {
      newPassword: true,
      confirmPassword: true
    };
    setTouched(newTouched);
    
    const passwordError = validatePassword(newPassword);
    const confirmError = validateConfirmPassword(newPassword, confirmPassword);
    
    const newErrors = {};
    if (passwordError) newErrors.newPassword = passwordError;
    if (confirmError) newErrors.confirmPassword = confirmError;
    
    setErrors(newErrors);
    
    if (Object.keys(newErrors).length === 0) {
      onSubmit();
    }
  };

  const togglePasswordVisibility = () => {
    setShowPassword(!showPassword);
  };

  const toggleConfirmPasswordVisibility = () => {
    setShowConfirmPassword(!showConfirmPassword);
  };

  return (
    <div className="reset-step">
      <h3>Create new password</h3>
      <p className="instruction-text">Your new password must be different from previous used passwords</p>
      
      <div className="auth-form-group auth-password-group">
        <label htmlFor="newPassword">New Password</label>
        <div className="auth-password-input-container">
          <input
            type={showPassword ? "text" : "password"}
            id="newPassword"
            placeholder="Enter new password"
            value={newPassword}
            onChange={handlePasswordChange}
            onFocus={() => setIsPasswordFocused(true)}
            onBlur={() => {
              setIsPasswordFocused(false);
              handleBlur('newPassword');
            }}
            maxLength="15"
            className={`auth-form-input ${touched.newPassword && errors.newPassword ? 'error' : ''}`}
          />
          <button 
            type="button" 
            className="password-toggle"
            onClick={togglePasswordVisibility}
          >
            {showPassword ? <EyeIcon /> : <EyeOffIcon />}
          </button>
        </div>
        
        {/* Password requirements display - exactly like SignUp component */}
        <PasswordRequirementsDisplay 
          password={newPassword} 
          isVisible={isPasswordFocused && newPassword.length > 0} 
        />
        
        {touched.newPassword && errors.newPassword && (
          <span className="error-message">{errors.newPassword}</span>
        )}
      </div>

      <div className="auth-form-group auth-password-group">
        <label htmlFor="confirmPassword">Confirm Password</label>
        <div className="auth-password-input-container">
          <input
            type={showConfirmPassword ? "text" : "password"}
            id="confirmPassword"
            placeholder="Confirm new password"
            value={confirmPassword}
            onChange={handleConfirmPasswordChange}
            onBlur={() => handleBlur('confirmPassword')}
            maxLength="15"
            className={`auth-form-input ${touched.confirmPassword && errors.confirmPassword ? 'error' : ''}`}
          />
          <button 
            type="button" 
            className="password-toggle"
            onClick={toggleConfirmPasswordVisibility}
          >
            {showConfirmPassword ? <EyeIcon /> : <EyeOffIcon />}
          </button>
        </div>
        {touched.confirmPassword && errors.confirmPassword && (
          <span className="error-message">{errors.confirmPassword}</span>
        )}
      </div>

      <div className="auth-btn-container">
        <button 
          onClick={handleSubmit} 
          className={`auth-btn ${isLoading ? 'loading' : ''}`}
          disabled={
            isLoading || Object.values(errors).some(error => error && error.length > 0)
          }
        >
          {isLoading ? "Updating..." : "Reset Password"}
        </button>
      </div>
    </div>
  );
};

export default PasswordStep;