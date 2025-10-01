/** @format */
import React, { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import './Profile.css';
import ProfileImageSection from './components/ProfileImageSection/ProfileImageSection';
import ProfileInfoSection from './components/ProfileInfoSection/ProfileInfoSection';
import ActionButtons from './components/ActionButtons/ActionButtons';
import UserIdentity from './components/UserIdentity/UserIdentity';
import HeaderPages from '../Common/HeaderPages';
import { maskPassword } from '../../utils/validations';
import API from '../../api/axios';

const Profile = () => {
  const navigate = useNavigate();
  const [isEditing, setIsEditing] = useState(false);
  const [userData, setUserData] = useState({
    name: '',
    email: '',
    mobile: '',
    password: '',
    confirmPassword: '',
    currentPassword: '',
    newPassword: '',
    countryCode: '+94',
  });
  const [originalData, setOriginalData] = useState({ ...userData });
  const [actualPassword, setActualPassword] = useState('');
  const [profileImage, setProfileImage] = useState(null);
  const [isSaveDisabled, setIsSaveDisabled] = useState(true);
  const [loading, setLoading] = useState(false);
  const [saveLoading, setSaveLoading] = useState(false);

  /** Load user profile (used both on mount and after save) **/
  const loadUserProfile = useCallback(async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('token') || localStorage.getItem('authToken');
      if (!token) return navigate('/signin');

      const response = await API.get('/api/users/profile');
      const data = response.data;

      let mobile = data.phone || '';
      if (mobile.startsWith(userData.countryCode)) {
        mobile = mobile.slice(userData.countryCode.length);
      }

      setUserData(prev => ({
        ...prev,
        name: data.name || '',
        email: data.email || '',
        mobile,
        password: '',
        confirmPassword: '',
        newPassword: '',
      }));

      setOriginalData(prev => ({
        ...prev,
        name: data.name || '',
        email: data.email || '',
        mobile,
      }));

      setProfileImage(data.profile_picture || null);
      setActualPassword('********');
    } catch (error) {
      console.error('Profile load error:', error);
      if (error.response?.status === 401) {
        localStorage.removeItem('token');
        localStorage.removeItem('authToken');
        navigate('/signin');
      } else {
        alert('Failed to load profile.');
      }
    } finally {
      setLoading(false);
    }
  }, [navigate, userData.countryCode]);

  useEffect(() => {
    loadUserProfile();
  }, [loadUserProfile]);

  const handleInputChange = (name, value) => {
    setUserData(prev => ({ ...prev, [name]: value }));
  };

  const handleEditClick = () => {
    setOriginalData({ ...userData });
    setIsEditing(true);
  };

  const handleCancelClick = () => {
    setUserData({ ...originalData });
    setIsEditing(false);
    setIsSaveDisabled(true);
  };

  /** Save updated profile **/
  const handleSave = async () => {
    // Validation
    const emailPattern = /^[^\s@]+@[^\s@]+\.com$/; // must contain @ and end with .com
    if (!userData.name.trim()) {
      return alert('Name cannot be empty.');
    }
    if (!emailPattern.test(userData.email)) {
      return alert('Please enter a valid email (must contain "@" and end with ".com").');
    }
    if (!/^\d{9}$/.test(userData.mobile)) {
      return alert('Mobile number must be exactly 9 digits.');
    }

    try {
      setSaveLoading(true);

      const payload = new FormData();
      payload.append('name', userData.name);
      payload.append('email', userData.email);

      let normalizedMobile = userData.mobile.replace(/^\+\d+/, '');
      payload.append('phone', `${userData.countryCode}${normalizedMobile}`);

      if (userData.newPassword) {
        payload.append('password', userData.newPassword);
      }

      if (profileImage && typeof profileImage !== 'string') {
        payload.append('profile_picture', profileImage);
      }

      await API.put('/api/users/profile', payload, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });

      // Reload profile from backend
      await loadUserProfile();
      setIsEditing(false);
      setIsSaveDisabled(true);
      alert('Profile updated successfully!');
    } catch (error) {
      console.error('Profile save error:', error);
      if (error.response?.status === 401) {
        localStorage.removeItem('token');
        localStorage.removeItem('authToken');
        navigate('/signin');
      } else {
        alert('Failed to update profile.');
      }
    } finally {
      setSaveLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="profile-container">
        <HeaderPages title="My Profile" onBack={() => navigate('/dashboard')} />
        <div className="profile-content">
          <div className="loading-message">Loading profile...</div>
        </div>
      </div>
    );
  }

  return (
    <div className="profile-container">
      <HeaderPages title="My Profile" onBack={() => navigate('/dashboard')} />

      <div className="profile-content">
        <div className="profile-card">
          <div className="profile-main-section">
            <ProfileImageSection
              profileImage={profileImage}
              isEditing={isEditing}
              onImageChange={setProfileImage}
              onRemovePhoto={() => setProfileImage(null)}
            />

            <div className="profile-info-container">
              <UserIdentity name={userData.name} isEditing={isEditing} />

              <ProfileInfoSection
                userData={userData}
                isEditing={isEditing}
                onInputChange={handleInputChange}
                actualPassword={actualPassword}
                maskPassword={maskPassword}
                passwordUpdated={!!userData.newPassword}
                onValidationChange={setIsSaveDisabled} // can remove if you want
              />
            </div>
          </div>

          <ActionButtons
            isEditing={isEditing}
            onEdit={handleEditClick}
            onCancel={handleCancelClick}
            onSave={handleSave}
            isSaveDisabled={isSaveDisabled || saveLoading}
            saveLoading={saveLoading}
          />
        </div>
      </div>
    </div>
  );
};

export default Profile;
