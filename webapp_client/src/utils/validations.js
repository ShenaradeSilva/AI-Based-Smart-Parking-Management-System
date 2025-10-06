import { countryCodes } from "./countryData";
import { validatePasswordMatch } from './auth';

// Contact form validation
export const validateContactForm = (formData) => {
  const errors = {};

  errors.name = validateName(formData.name);
  errors.email = validateEmail(formData.email);

  if (!formData.message.trim()) {
    errors.message = 'Message is required';
  } else if (formData.message.trim().length < 10) {
    errors.message = 'Message must be at least 10 characters long';
  }

  Object.keys(errors).forEach(key => {
    if (!errors[key]) delete errors[key];
  });

  return errors;
};

// Password requirements configuration
export const passwordRequirements = [
  { id: 'length', test: (pw) => pw.length >= 8 && pw.length <= 15, label: '8-15 characters' },
  { id: 'lowercase', test: (pw) => /[a-z]/.test(pw), label: 'At least one lowercase letter' },
  { id: 'uppercase', test: (pw) => /[A-Z]/.test(pw), label: 'At least one uppercase letter' },
  { id: 'number', test: (pw) => /\d/.test(pw), label: 'At least one number' },
  { id: 'special', test: (pw) => /[@$!%*?&]/.test(pw), label: 'At least one special character (@$!%*?&)' },
];

// Helper functions
export const getDigitsForCountry = (countryCode) => {
  const cleanCountryCode = countryCode.includes('-') 
    ? countryCode.split('-')[0] 
    : countryCode;

  const country = countryCodes.find(c => c.code === cleanCountryCode);
  return country ? country.digits : 10;
};

export const getCountryName = (countryCode) => {
  const cleanCountryCode = countryCode.includes('-') 
    ? countryCode.split('-')[0] 
    : countryCode;

  const country = countryCodes.find(c => c.code === cleanCountryCode);
  return country ? country.name : 'Unknown';
};

// Field validations
export const validateConfirmPassword = (password, confirmPassword) => {
  if (!confirmPassword) return 'Please confirm your password';
  if (password !== confirmPassword) return 'Passwords do not match';
  return '';
};

// Email validation
export const validateEmail = (email) => {
  if (!email.trim()) return 'Email is required';
  if (!/@/.test(email) || !/\.com$/.test(email)) return 'Email must include @ and end with .com';
  return '';
};

// Name validation
export const validateName = (name) => {
  if (!name.trim()) return 'Name is required';
  if (name.trim().length < 2) return 'Name must be at least 2 characters long';
  if (!/^[a-zA-Z\s]+$/.test(name.trim())) return 'Name can only contain letters and spaces';
  return '';
};

// Password validation
export const validatePassword = (password) => {
  if (!password) return 'Password is required';
  
  for (const req of passwordRequirements) {
    if (!req.test(password)) {
      return 'Password does not meet all requirements';
    }
  }
  return '';
};

export const validatePasswordSignIn = (password, email = '') => {
  if (!password) return 'Password is required';
  if (password.length < 8) return 'Password must be at least 8 characters';
  
  if (email) {
    const passwordMatchError = validatePasswordMatch(email, password);
    if (passwordMatchError) return passwordMatchError;
  }

  return '';
};

// Mobile number validation (exactly 9 digits)
export const validatePhoneNumber = (phone, countryCode = '+94') => {
    if (!phone) return 'Phone number is required';
    if (!/^\d{9}$/.test(phone)) return 'Phone number must be exactly 9 digits';
    return '';
};

// Verification code validation
export const validateVerificationCode = (code) => {
  if (!code) return 'Verification code is required';
  if (code.length !== 4) return 'Code must be exactly 4 digits';
  if (!/^\d+$/.test(code)) return 'Code must contain only numbers';
  return '';
};

// Form validations
export const validateSignInForm = (formData) => {
  const errors = {};
  errors.email = validateEmail(formData.email);
  errors.password = validatePasswordSignIn(formData.password, formData.email);

  Object.keys(errors).forEach(key => {
    if (!errors[key]) delete errors[key];
  });

  return errors;
};

export const validateSignUpForm = (formData) => {
  const errors = {};
  errors.name = validateName(formData.name);
  errors.email = validateEmail(formData.email);
  errors.mobile = validatePhoneNumber(formData.mobile);
  errors.password = validatePassword(formData.password);
  errors.confirmPassword = validateConfirmPassword(formData.password, formData.confirmPassword);

  Object.keys(errors).forEach(key => {
    if (!errors[key]) delete errors[key];
  });

  return errors;
};

export const validateVerificationForm = (formData) => {
  const errors = {};
  errors.code = validateVerificationCode(formData.code);
  Object.keys(errors).forEach(key => {
    if (!errors[key]) delete errors[key];
  });
  return errors;
};

// Utilities
export const clearError = (errors, fieldName) => {
  const newErrors = { ...errors };
  delete newErrors[fieldName];
  return newErrors;
};

export const validateImageFile = (file) => {
  if (!file) return 'No file selected';
  
  // Check file type
  const validTypes = ['image/jpeg', 'image/jpg', 'image/png'];
  if (!validTypes.includes(file.type)) {
    return 'Please select a valid image file (JPEG or PNG only)';
  }
  
  // Check file size (5MB max)
  const maxSize = 5 * 1024 * 1024; // 5MB in bytes
  if (file.size > maxSize) {
    return 'Image size must be less than 5MB';
  }
  
  // Check file name length
  if (file.name.length > 255) {
    return 'File name is too long';
  }
  
  return null;
};

export const maskPassword = (password) => {
  if (!password) return '';
  return '•'.repeat(Math.min(password.length, 12));
};

// Validate a single field dynamically
export const validateField = (fieldName, value, additionalData = {}) => {
  switch (fieldName) {
    case 'name':
      return validateName(value);
    case 'email':
      return validateEmail(value);
    case 'password':
      return validatePassword(value);
    case 'confirmPassword':
      return validateConfirmPassword(additionalData.password, value);
    case 'mobile':
      return validatePhoneNumber(value);
    case 'code':
      return validateVerificationCode(value);
    case 'profileImage':
      return validateImageFile(value);
    default:
      return '';
  }
};
