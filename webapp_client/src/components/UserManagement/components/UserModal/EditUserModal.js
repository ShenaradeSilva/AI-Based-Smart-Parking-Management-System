import React, { useState } from 'react';
import './UserModal.css';
import { ApproveIcon, RejectIcon, CloseIcon } from '../../../Icons/Icons';
import { validateName, validateEmail, validatePhoneNumber } from '../../../../utils/validations';
import { countryCodes } from '../../../../utils/countryData';

const EditUserModal = ({ user, onClose, onSave }) => {
    // Split user's phone into country code + number
    const getCountryCode = (phone) => {
        if (!phone) return '+94'; // default
        const match = countryCodes.find((c) => phone.startsWith(c.code));
        return match ? match.code : '+94';
    };

    const stripCountryCode = (phone, code) => {
        return phone?.startsWith(code) ? phone.slice(code.length) : phone || '';
    };

    const initialCode = getCountryCode(user.phone);

    const [formData, setFormData] = useState({
        name: user.name,
        email: user.email,
        countryCode: initialCode,
        phone: stripCountryCode(user.phone, initialCode),
        role: user.role,
        status: user.status
    });

    const [errors, setErrors] = useState({});

    // ✅ All fields are now editable
    const handleChange = (e) => {
        const { name, value } = e.target;

        let processedValue = value;

        // Allow only digits and limit length for phone field
        if (name === "phone") {
            processedValue = value.replace(/\D/g, '').slice(0, 9);
        }

        setFormData(prev => ({ ...prev, [name]: processedValue }));

        // Validate on change
        let errorMessage = '';
        if (name === 'name') errorMessage = validateName(processedValue);
        if (name === 'email') errorMessage = validateEmail(processedValue);
        if (name === 'phone') errorMessage = validatePhoneNumber(processedValue, formData.countryCode);

        setErrors(prev => ({ ...prev, [name]: errorMessage }));
    };
    const validateForm = () => {
        const newErrors = {};

        const nameError = validateName(formData.name);
        if (nameError) newErrors.name = nameError;

        const emailError = validateEmail(formData.email);
        if (emailError) newErrors.email = emailError;

        const phoneError = validatePhoneNumber(formData.phone, formData.countryCode);
        if (phoneError) newErrors.phone = phoneError;

        setErrors(newErrors);

        // Return true if no errors
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        if (validateForm()) {
            const updatedUser = {
                ...user,
                name: formData.name,
                email: formData.email,
                phone: `${formData.countryCode}${formData.phone}`,
                role: formData.role,
                status: formData.status
            };
            onSave(updatedUser);
        }
    };

    return (
        <div className="modal-overlay">
            <div className="modal-content">
                <div className="modal-header">
                    <h3>Edit User</h3>
                    <button className="close-btn" onClick={onClose}>
                        <CloseIcon />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="user-form">
                    {/* Name */}
                    <label>Name:</label>
                    <input
                        type="text"
                        name="name"
                        value={formData.name}
                        onChange={handleChange}
                        className={errors.name ? 'error' : ''}
                    />
                    {errors.name && <span className="error-text">{errors.name}</span>}

                    {/* Email */}
                    <label>Email:</label>
                    <input
                        type="email"
                        name="email"
                        value={formData.email}
                        onChange={handleChange}
                        className={errors.email ? 'error' : ''}
                    />
                    {errors.email && <span className="error-text">{errors.email}</span>}

                    {/* Phone */}
                    <label>Phone:</label>
                    <div className="phone-input-container">
                        <select
                            name="countryCode"
                            value={formData.countryCode}
                            onChange={handleChange}
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
                            name="phone"
                            value={formData.phone}
                            onChange={handleChange}
                            className={errors.phone ? 'error' : ''}
                            placeholder="Enter phone number"
                        />
                    </div>
                    {errors.phone && <span className="error-text">{errors.phone}</span>}

                    {/* Role */}
                    <label>Role:</label>
                    <select
                        name="role"
                        value={formData.role}
                        onChange={handleChange}
                    >
                        <option value="driver">Driver</option>
                        <option value="admin">Admin</option>
                    </select>

                    {/* Status */}
                    <label>Status:</label>
                    <select
                        name="status"
                        value={formData.status}
                        onChange={handleChange}
                    >
                        <option value="active">Active</option>
                        <option value="inactive">Inactive</option>
                    </select>

                    {/* Buttons */}
                    <div className="modal-buttons">
                        <button type="button" className="btn btn-secondary" onClick={onClose}>
                            <RejectIcon /> Cancel
                        </button>
                        <button type="submit" className="btn btn-primary">
                            <ApproveIcon /> Save
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default EditUserModal;
