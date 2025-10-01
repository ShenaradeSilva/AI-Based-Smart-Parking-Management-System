import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './SignIn.css';
import '../common/AuthCommon.css';
import { Logo1 } from '../../Logos/Logos';
import { CloseIcon, EyeIcon, EyeOffIcon } from '../../Icons/Icons';
import { validateEmail } from '../../../utils/validations';
import API from '../../../api/axios';

const SignIn = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [errors, setErrors] = useState({});
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false); // optional loading state
  const [serverError, setServerError] = useState('');

  const handleClose = () => {
    navigate('/');
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    if (errors[name]) setErrors(prev => ({ ...prev, [name]: '' }));
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleBlur = (e) => {
    const { name, value } = e.target;
    if (value) {
      const newErrors = { ...errors };
      if (name === 'email') newErrors.email = validateEmail(value);
      Object.keys(newErrors).forEach(key => {
        if (!newErrors[key]) delete newErrors[key];
      });
      setErrors(newErrors);
    }
  };

  const validateForm = () => {
    const newErrors = {};
    if (!formData.email) newErrors.email = 'Email is required';
    else {
      const emailError = validateEmail(formData.email);
      if (emailError) newErrors.email = emailError;
    }
    if (!formData.password) newErrors.password = 'Password is required';
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setServerError('');
    if (!validateForm()) return;

    try {
      setLoading(true);
      const response = await API.post('/api/auth/signin', {
        email: formData.email,
        password: formData.password
      });

      const { access_token, user} = response.data;

      // Save the JWT token in localStorage
      localStorage.setItem('authToken', access_token);

      navigate('/dashboard');
    } catch (error) {
      console.error(error);
      if (error.response && error.response.data.detail) {
        setServerError(error.response.data.detail);
      } else {
        setServerError('Login failed. Please try again.');
      }
    } finally {
      setLoading(false);
    }
  };

  const togglePasswordVisibility = () => {
    setShowPassword(!showPassword);
  };

  return (
    <div className="auth-container">
      <div className="auth-card">
        <button className="auth-close-btn" onClick={handleClose}>
          <CloseIcon />
        </button>
        
        <div className='auth-header'>
          <Logo1 />
          <div className='auth-text'>
            <h2>Sign In to your Account</h2>
          </div>
        </div>        
        
        <form className="auth-form" onSubmit={handleSubmit}>
          {serverError && <div className="server-error">{serverError}</div>}

          <div className="auth-form-group">
            <label htmlFor="email">Email</label>
            <input 
              type="email" 
              id="email" 
              name="email" 
              value={formData.email}
              onChange={handleInputChange}
              onBlur={handleBlur}
              required
              className={errors.email ? 'error' : ''}
            />
            {errors.email && <span className="error-message">{errors.email}</span>}
          </div>
          
          <div className="auth-form-group auth-password-group">
            <label htmlFor="password">Password</label>
            <div className="auth-password-input-container">
              <input 
                type={showPassword ? "text" : "password"} 
                id="password" 
                name="password" 
                maxLength="15"
                placeholder="Enter your password" 
                value={formData.password}
                onChange={handleInputChange}
                onBlur={handleBlur}
                required 
                className={errors.password ? 'error' : ''}
              />
              <button 
                type="button" 
                className="password-toggle"
                onClick={togglePasswordVisibility}
              >
                {showPassword ? <EyeIcon /> : <EyeOffIcon />}
              </button>
            </div>
            {errors.password && <span className="error-message">{errors.password}</span>}
          </div>
          
          <p className="forgot-password-link">
            <a href="/resetpassword">Forgot Password?</a>
          </p>
          
          <div className="auth-btn-container">
            <button type="submit" className="auth-btn" disabled={loading}>
              {loading ? 'Signing in...' : 'Sign In'}
            </button>
          </div>
        </form>
        
        <p className="auth-link">Don't have an account? <a href="/signup">Sign Up!</a></p>
      </div>
    </div>
  );
};

export default SignIn;
