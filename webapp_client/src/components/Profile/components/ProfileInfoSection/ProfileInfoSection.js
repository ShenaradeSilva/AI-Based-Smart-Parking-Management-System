import React, { useState, useEffect } from "react";
import "./ProfileInfoSection.css";
import { validateField } from "../../../../utils/validations";
import PasswordRequirementsDisplay from "../../../Auth/common/PasswordRequirementsDisplay";
import { countryCodes } from "../../../../utils/countryData";
import { EyeIcon, EyeOffIcon } from "../../../Icons/Icons";

const ProfileInfoSection = ({
  userData,
  isEditing,
  onInputChange,
  onValidationChange,
  passwordUpdated,
  actualPassword,
  maskPassword
}) => {
  const [errors, setErrors] = useState({});
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [isNewPasswordFocused, setIsNewPasswordFocused] = useState(false);

  useEffect(() => {
    if (isEditing) {
      validateAllFields();
    }
  }, [isEditing]);

  // Validate fields and notify parent
  useEffect(() => {
    if (onValidationChange) {
      const hasErrors = Object.values(errors).some(error => error !== undefined && error !== '');
      const isPasswordChanging = userData.newPassword && userData.newPassword.trim() !== "";
      
      // Check if required fields are filled
      const requiredFieldsFilled = userData.name.trim() && userData.email.trim() && userData.mobile.trim();
      
      // Check password requirements if changing password
      const passwordValid = !isPasswordChanging || (
        userData.currentPassword && 
        userData.newPassword && 
        userData.confirmPassword &&
        userData.newPassword === userData.confirmPassword
      );

      const shouldDisableSave = hasErrors || !requiredFieldsFilled || !passwordValid;
      onValidationChange(shouldDisableSave);
    }
  }, [errors, userData, onValidationChange]);

  const validateAllFields = () => {
    const newErrors = {
      name: validateField("name", userData.name || ""),
      email: validateField("email", userData.email || ""),
      mobile: validateField("mobile", userData.mobile || "")
    };

    // Password validation only when changing password
    if (userData.newPassword && userData.newPassword.trim() !== "") {
      newErrors.newPassword = validateField("password", userData.newPassword);
      
      if (!userData.currentPassword || userData.currentPassword.trim() === "") {
        newErrors.currentPassword = "Current password is required to change password";
      }

      newErrors.confirmPassword = validateField(
        "confirmPassword",
        userData.confirmPassword || "",
        { password: userData.newPassword }
      );
    }

    setErrors(newErrors);
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    let processedValue = value;

    // Input sanitization
    if (name === "name") {
      processedValue = value.replace(/[^A-Za-z\s]/g, "");
    }
    if (name === "mobile") {
      processedValue = value.replace(/\D/g, "").slice(0, 9);
    }

    // Validate the field
    const validationError = validateField(name, processedValue, {
      password: name === "confirmPassword" ? userData.newPassword : undefined
    });

    setErrors(prev => {
      const updatedErrors = { ...prev, [name]: validationError };

      // Special handling for password fields
      if (name === "newPassword" && processedValue.trim() !== "") {
        if (!userData.currentPassword || userData.currentPassword.trim() === "") {
          updatedErrors.currentPassword = "Current password is required to change password";
        }
      }

      if (name === "currentPassword" && processedValue.trim() !== "") {
        delete updatedErrors.currentPassword;
      }

      return updatedErrors;
    });

    onInputChange(name, processedValue);
  };

  const handleCountryCodeChange = (e) => {
    const newCode = e.target.value;
    onInputChange("countryCode", newCode);
  };

  return (
    <div className="profile-info-section">
      <div className="info-grid">
        {/* NAME */}
        <div className="info-item">
          <label>Name</label>
          {isEditing ? (
            <div className="input-container">
              <input
                type="text"
                name="name"
                value={userData.name || ""}
                onChange={handleInputChange}
                placeholder="Enter your name"
                className={errors.name ? "error" : ""}
              />
              {errors.name && <span className="error-message">{errors.name}</span>}
            </div>
          ) : (
            <p className="info-value">{userData.name || "Not set"}</p>
          )}
        </div>

        {/* EMAIL */}
        <div className="info-item">
          <label>Email</label>
          {isEditing ? (
            <div className="input-container">
              <input
                type="email"
                name="email"
                value={userData.email || ""}
                onChange={handleInputChange}
                placeholder="Enter your email"
                className={errors.email ? "error" : ""}
              />
              {errors.email && <span className="error-message">{errors.email}</span>}
            </div>
          ) : (
            <p className="info-value">{userData.email || "Not set"}</p>
          )}
        </div>

        {/* MOBILE */}
        <div className="info-item">
          <label>Mobile No</label>
          {isEditing ? (
            <div className="mobile-input-container">
              <div className="input-container">
                <div className="mobile-input-wrapper">
                  <select
                    value={userData.countryCode || "+94"}
                    onChange={handleCountryCodeChange}
                    className="country-code-select"
                  >
                    {countryCodes.map((country) => (
                      <option key={country.code} value={country.code}>
                        {country.code}
                      </option>
                    ))}
                  </select>
                  <input
                    type="tel"
                    name="mobile"
                    value={userData.mobile || ""}
                    onChange={handleInputChange}
                    placeholder="Enter 9-digit number"
                    className={`mobile-number-input ${errors.mobile ? "error" : ""}`}
                    maxLength="9"
                  />
                </div>
                {errors.mobile && <span className="error-message">{errors.mobile}</span>}
              </div>
            </div>
          ) : (
            <p className="info-value">
              {userData.countryCode} {userData.mobile || "Not set"}
            </p>
          )}
        </div>

        {/* CURRENT PASSWORD - Only show when changing password */}
        {isEditing && userData.newPassword && userData.newPassword.trim() !== "" && (
          <div className="info-item">
            <label>Current Password</label>
            <div className="input-container">
              <div className="password-input-container">
                <input
                  type={showCurrentPassword ? "text" : "password"}
                  name="currentPassword"
                  value={userData.currentPassword || ""}
                  onChange={handleInputChange}
                  placeholder="Enter your current password"
                  className={errors.currentPassword ? "error" : ""}
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                >
                  {showCurrentPassword ? <EyeOffIcon /> : <EyeIcon />}
                </button>
              </div>
              {errors.currentPassword && (
                <span className="error-message">{errors.currentPassword}</span>
              )}
            </div>
          </div>
        )}

        {/* NEW PASSWORD */}
        {isEditing && (
          <div className="info-item">
            <label>New Password</label>
            <div className="input-container">
              <div className="password-input-container">
                <input
                  type={showNewPassword ? "text" : "password"}
                  name="newPassword"
                  value={userData.newPassword || ""}
                  onChange={handleInputChange}
                  onFocus={() => setIsNewPasswordFocused(true)}
                  onBlur={() => setIsNewPasswordFocused(false)}
                  placeholder="Enter new password (optional)"
                  className={errors.newPassword ? "error" : ""}
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={() => setShowNewPassword(!showNewPassword)}
                >
                  {showNewPassword ? <EyeOffIcon /> : <EyeIcon />}
                </button>
              </div>

              {isNewPasswordFocused && (
                <PasswordRequirementsDisplay
                  password={userData.newPassword || ""}
                  isVisible={isNewPasswordFocused}
                />
              )}

              {errors.newPassword && (
                <span className="error-message">{errors.newPassword}</span>
              )}
            </div>
          </div>
        )}

        {/* CONFIRM PASSWORD - Only show when new password is entered */}
        {isEditing && userData.newPassword && userData.newPassword.trim() !== "" && (
          <div className="info-item">
            <label>Confirm New Password</label>
            <div className="input-container">
              <div className="password-input-container">
                <input
                  type={showConfirmPassword ? "text" : "password"}
                  name="confirmPassword"
                  value={userData.confirmPassword || ""}
                  onChange={handleInputChange}
                  placeholder="Confirm new password"
                  className={errors.confirmPassword ? "error" : ""}
                />
                <button
                  type="button"
                  className="password-toggle"
                  onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                >
                  {showConfirmPassword ? <EyeOffIcon /> : <EyeIcon />}
                </button>
              </div>
              {errors.confirmPassword && (
                <span className="error-message">{errors.confirmPassword}</span>
              )}
            </div>
          </div>
        )}

        {/* PASSWORD DISPLAY - Only in view mode */}
        {!isEditing && (
          <div className="info-item">
            <label>Password</label>
            <div className="password-display">
              <p className="info-value">{maskPassword(actualPassword)}</p>
              {passwordUpdated && (
                <span className="password-updated-indicator" title="Password was recently updated">
                  Updated
                </span>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ProfileInfoSection;