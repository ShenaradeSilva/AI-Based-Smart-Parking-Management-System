import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './SignUp.css';
import '../common/AuthCommon.css';
import { Logo1 } from '../../Logos/Logos';
import { CloseIcon, EyeIcon, EyeOffIcon } from '../../Icons/Icons';
import TermsModal from './TermsModal';
import PrivacyModal from './PrivacyModal';
import { validateSignUpForm, getDigitsForCountry, validateField, clearError } from '../../../utils/validations';
import PasswordRequirementsDisplay from '../common/PasswordRequirementsDisplay';
import { countryCodes } from '../../../utils/countryData';
import API from '../../../api/axios';

const SignUp = () => {
  const navigate = useNavigate();
  const [showTerms, setShowTerms] = useState(false);
  const [showPrivacy, setShowPrivacy] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState({});
  const [touched, setTouched] = useState({});
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isPasswordFocused, setIsPasswordFocused] = useState(false);

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    confirmPassword: '',
    countryCode: '+94',
    phone: '',
    role: 'admin', // default role
  });

  const handleClose = () => navigate('/');
  const requiredDigits = getDigitsForCountry(formData.countryCode);

  const validateForm = () => {
    const newErrors = validateSignUpForm({ ...formData, mobile: formData.phone });
    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = "Passwords do not match";
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleBlur = (fieldName) => {
    setTouched(prev => ({ ...prev, [fieldName]: true }));
    let error = fieldName === 'phone'
      ? validateField('mobile', formData.phone, { countryCode: formData.countryCode })
      : validateField(fieldName, formData[fieldName], { password: formData.password, confirmPassword: formData.confirmPassword });

    if (error) setErrors(prev => ({ ...prev, [fieldName]: error }));
    else setErrors(prev => clearError(prev, fieldName));
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    if (errors[name]) setErrors(prev => clearError(prev, name));

    if (name === 'phone') {
      const digits = value.replace(/\D/g, '').slice(0, requiredDigits);
      setFormData(prev => ({ ...prev, phone: digits }));
      return;
    }

    setFormData(prev => ({ ...prev, [name]: value }));

    if (name === 'password' && formData.confirmPassword && touched.confirmPassword) {
      const confirmError = validateField('confirmPassword', formData.confirmPassword, { password: value });
      setErrors(prev => ({ ...prev, confirmPassword: confirmError }));
    }
  };

  const handleCountryCodeChange = (e) => {
    const newCode = e.target.value;
    const newDigits = getDigitsForCountry(newCode);
    setFormData(prev => ({
      ...prev,
      countryCode: newCode,
      phone: prev.phone.slice(0, newDigits)
    }));
    if (errors.phone) setErrors(prev => clearError(prev, 'phone'));
    if (touched.phone) {
      const phoneError = validateField('mobile', formData.phone, { countryCode: newCode });
      if (phoneError) setErrors(prev => ({ ...prev, phone: phoneError }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setTouched({ name: true, email: true, phone: true, password: true, confirmPassword: true, role: true });
    if (!validateForm()) return;

    const fullPhone = formData.countryCode + formData.phone;

    setIsLoading(true);
    try {
      const payload = {
        name: formData.name.trim(),
        email: formData.email.trim().toLowerCase(),
        password: formData.password,
        phone: fullPhone || null,
        role: formData.role, // send selected role
      };

      await API.post('/api/auth/signup', payload);
      navigate('/signin');
    } catch (err) {
      setErrors(prev => ({
        ...prev,
        apiError: err.response?.data?.detail || "Signup failed. Please try again."
      }));
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-blue-background"></div>
      <div className="auth-card">
        <button className="auth-close-btn" onClick={handleClose}><CloseIcon /></button>
        <div className='auth-header'>
          <Logo1 />
          <div className='auth-text'><h2>Create your Account</h2></div>
        </div>

        <form className="auth-form" onSubmit={handleSubmit}>
          {errors.apiError && <span className="error-message">{errors.apiError}</span>}

          {/* Name */}
          <div className="auth-form-group">
            <label htmlFor="name">Name</label>
            <input type="text" name="name" value={formData.name} onChange={handleInputChange} onBlur={() => handleBlur('name')}
              className={touched.name && errors.name ? 'error' : ''} required />
            {touched.name && errors.name && <span className="error-message">{errors.name}</span>}
          </div>

          {/* Email */}
          <div className="auth-form-group">
            <label htmlFor="email">Email</label>
            <input type="email" name="email" value={formData.email} onChange={handleInputChange} onBlur={() => handleBlur('email')}
              className={touched.email && errors.email ? 'error' : ''} required />
            {touched.email && errors.email && <span className="error-message">{errors.email}</span>}
          </div>

          {/* Phone */}
          <div className="auth-form-group">
            <label htmlFor="phone">Phone Number</label>
            <div className="mobile-input-container">
              <select value={formData.countryCode} onChange={handleCountryCodeChange} className="country-code-select">
                {countryCodes.map((c) => <option key={c.code} value={c.code}>{c.code} ({c.name})</option>)}
              </select>
              <input type="tel" name="phone" value={formData.phone} onChange={handleInputChange} onBlur={() => handleBlur('phone')}
                placeholder={`Enter ${requiredDigits}-digit number`} className={`mobile-number-input ${touched.phone && errors.phone ? 'error' : ''}`} required />
            </div>
            {touched.phone && errors.phone && <span className="error-message">{errors.phone}</span>}
          </div>

          {/* Password */}
          <div className="auth-form-group auth-password-group">
            <label>Password</label>
            <div className="auth-password-input-container">
              <input type={showPassword ? 'text' : 'password'} name="password" value={formData.password} onChange={handleInputChange}
                onFocus={() => setIsPasswordFocused(true)} onBlur={() => { setIsPasswordFocused(false); handleBlur('password'); }}
                className={touched.password && errors.password ? 'error' : ''} maxLength="100" required />
              <button type="button" className="password-toggle" onClick={() => setShowPassword(!showPassword)}>
                {showPassword ? <EyeIcon /> : <EyeOffIcon />}
              </button>
            </div>
            <PasswordRequirementsDisplay password={formData.password} isVisible={isPasswordFocused && formData.password.length > 0} />
            {touched.password && errors.password && <span className="error-message">{errors.password}</span>}
          </div>

          {/* Confirm Password */}
          <div className="auth-form-group auth-password-group">
            <label>Confirm Password</label>
            <div className="auth-password-input-container">
              <input type={showConfirmPassword ? 'text' : 'password'} name="confirmPassword" value={formData.confirmPassword}
                onChange={handleInputChange} onBlur={() => handleBlur('confirmPassword')}
                className={touched.confirmPassword && errors.confirmPassword ? 'error' : ''} required />
              <button type="button" className="password-toggle" onClick={() => setShowConfirmPassword(!showConfirmPassword)}>
                {showConfirmPassword ? <EyeIcon /> : <EyeOffIcon />}
              </button>
            </div>
            {touched.confirmPassword && errors.confirmPassword && <span className="error-message">{errors.confirmPassword}</span>}
          </div>

          {/* Terms */}
          <div className="checkbox-group">
            <input type="checkbox" id="terms" required />
            <label htmlFor="terms">
              Agree to <a href="#" onClick={(e) => { e.preventDefault(); setShowTerms(true); }}>Terms & Conditions</a> and
              <a href="#" onClick={(e) => { e.preventDefault(); setShowPrivacy(true); }}> Privacy Policy</a>
            </label>
          </div>

          <div className="auth-btn-container">
            <button type="submit" className="auth-btn" disabled={isLoading}>
              {isLoading ? 'Creating Account...' : 'Sign Up'}
            </button>
          </div>
        </form>

        <p className="auth-link">Have an account? <a href="/signin">Sign In!</a></p>
      </div>

      {showTerms && <TermsModal onClose={() => setShowTerms(false)} />}
      {showPrivacy && <PrivacyModal onClose={() => setShowPrivacy(false)} />}
    </div>
  );
};

export default SignUp;
