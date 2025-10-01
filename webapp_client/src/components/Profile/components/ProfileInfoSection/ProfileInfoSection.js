import React, { useState, useEffect } from "react";
import "./ProfileInfoSection.css";
import { passwordRequirements, getDigitsForCountry, validateField } from "../../../../utils/validations";
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
    if (isEditing) validateAllFields();
  }, [isEditing]);

  // Notify parent about validation state
  useEffect(() => {
    if (onValidationChange) {
      const isPasswordChanging = userData.newPassword && userData.newPassword !== "";
      const allValid =
        !errors.name &&
        !errors.email &&
        !errors.mobile &&
        (!isPasswordChanging ||
          (userData.currentPassword && !errors.currentPassword && !errors.newPassword && !errors.confirmPassword));
      onValidationChange(!allValid); // true disables save, false enables save
    }
  }, [errors, userData.newPassword, userData.currentPassword]);

  /** VALIDATE ALL FIELDS **/
  const validateAllFields = () => {
    const newErrors = {
      name: validateField("name", userData.name || ""),
      email: validateField("email", userData.email || ""),
      mobile: validateField("mobile", userData.mobile || "")
    };

    // If new password is entered, current password is required
    if (userData.newPassword && userData.newPassword.trim() !== "") {
      if (!userData.currentPassword || userData.currentPassword.trim() === "") {
        newErrors.currentPassword = "Current password is required to change password";
      }

      newErrors.newPassword = validateField("password", userData.newPassword);
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

    if (name === "name") processedValue = value.replace(/[^A-Za-z\s]/g, "");
    if (name === "mobile") processedValue = value.replace(/\D/g, "").slice(0, 9);

    const validationError = validateField(name, processedValue, {
      password: name === "confirmPassword" ? userData.newPassword : undefined
    });

    setErrors((prev) => {
      const updatedErrors = { ...prev, [name]: validationError };

      // If typing new password, also check current password
      if (name === "newPassword" && processedValue.trim() !== "" && (!userData.currentPassword || userData.currentPassword.trim() === "")) {
        updatedErrors.currentPassword = "Current password is required to change password";
      }

      // Remove error if current password is filled
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
    setErrors((prev) => ({
      ...prev,
      mobile: validateField("mobile", userData.mobile || "", { countryCode: newCode })
    }));
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
                        {country.code} ({country.name})
                      </option>
                    ))}
                  </select>
                  <input
                    type="tel"
                    name="mobile"
                    value={userData.mobile || ""}
                    onChange={handleInputChange}
                    placeholder={`Enter 9-digit number`}
                    className={`mobile-number-input ${errors.mobile ? "error" : ""}`}
                  />
                </div>
                {errors.mobile && <span className="error-message">{errors.mobile}</span>}
              </div>
            </div>
          ) : (
            <p className="info-value">
              {userData.countryCode || "+94"} {userData.mobile || "Not set"}
            </p>
          )}
        </div>

        {/* CURRENT PASSWORD */}
        {isEditing && userData.newPassword && (
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
                  placeholder="Enter new password (leave empty for current)"
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

              <PasswordRequirementsDisplay
                password={userData.newPassword || ""}
                isVisible={isNewPasswordFocused}
              />

              {errors.newPassword && (
                <span className="error-message">{errors.newPassword}</span>
              )}
            </div>
          </div>
        )}

        {/* CONFIRM PASSWORD */}
        {isEditing && userData.newPassword && userData.newPassword !== "" && (
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

        {/* PASSWORD DISPLAY */}
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
