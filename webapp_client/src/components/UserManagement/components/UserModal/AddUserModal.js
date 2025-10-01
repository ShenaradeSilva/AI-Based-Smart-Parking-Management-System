import React, { useState } from 'react';
import './UserModal.css';
import { RejectIcon, AddIcon, CloseIcon } from '../../../Icons/Icons';
import { validateEmail, validateName, validatePhoneNumber } from '../../../../utils/validations';
import { countryCodes } from '../../../../utils/countryData';

const AddUserModal = ({ onClose, onSave, existingEmails }) => {
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        countryCode: '+94',
        phone: '',
        role: 'driver',
        status: 'active',
        sendCredentials: true
    });

    const [errors, setErrors] = useState({});

    const handleChange = (e) => {
        const { name, value, type, checked } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : value
        }));

        if (errors[name]) {
            setErrors(prev => {
                const updated = { ...prev };
                delete updated[name];
                return updated;
            });
        }
    };

    const validateForm = () => {
        const newErrors = {};

        const nameError = validateName(formData.name);
        if (nameError) newErrors.name = nameError;

        const emailError = validateEmail(formData.email);
        if (emailError) newErrors.email = emailError;
        else if (existingEmails.includes(formData.email)) {
            newErrors.email = 'This email is already registered';
        }

        const phoneError = validatePhoneNumber(formData.phone, formData.countryCode);
        if (phoneError) newErrors.phone = phoneError;

        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        if (validateForm()) {
            const dataToSave = {
                ...formData,
                phone: `${formData.countryCode}${formData.phone}`
            };
            onSave(dataToSave);
        }
    };

    return (
        <div className="modal-overlay">
            <div className="modal-content">
                <div className="modal-header">
                    <h3>Add New User</h3>
                    <button className="close-btn" onClick={onClose}>
                        <CloseIcon />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="user-form">
                    <div className="form-group">
                        <label>Full Name *</label>
                        <input
                            type="text"
                            name="name"
                            value={formData.name}
                            onChange={handleChange}
                            className={errors.name ? 'error' : ''}
                        />
                        {errors.name && <span className="error-text">{errors.name}</span>}
                    </div>

                    <div className="form-group">
                        <label>Email *</label>
                        <input
                            type="email"
                            name="email"
                            value={formData.email}
                            onChange={handleChange}
                            className={errors.email ? 'error' : ''}
                        />
                        {errors.email && <span className="error-text">{errors.email}</span>}
                    </div>

                    <div className="form-group">
                        <label>Phone *</label>
                        <div className="phone-input-container">
                            <select
                                name="countryCode"
                                value={formData.countryCode}
                                onChange={handleChange}
                                className="country-code-select"
                            >
                                {countryCodes.map((country) => (
                                    <option key={country.code} value={country.code}>
                                        {country.code} {country.name}
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
                    </div>

                    <div className="form-group">
                        <label>Role *</label>
                        <select
                            name="role"
                            value={formData.role}
                            onChange={handleChange}
                            required
                        >
                            <option value="driver">Driver</option>
                            <option value="admin">Admin</option>
                        </select>
                    </div>

                    <div className="form-group">
                        <label>Status *</label>
                        <select
                            name="status"
                            value={formData.status}
                            onChange={handleChange}
                            required
                        >
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                        </select>
                    </div>

                    <div className="form-group checkbox-group">
                        <label>
                            <input
                                type="checkbox"
                                name="sendCredentials"
                                checked={formData.sendCredentials}
                                onChange={handleChange}
                            />
                            Send login credentials via email
                        </label>
                    </div>

                    <div className="modal-buttons">
                        <button type="button" onClick={onClose} className="btn btn-secondary">
                            <RejectIcon /> Cancel
                        </button>
                        <button type="submit" className="btn btn-primary">
                            <AddIcon /> Add User
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
};

export default AddUserModal;