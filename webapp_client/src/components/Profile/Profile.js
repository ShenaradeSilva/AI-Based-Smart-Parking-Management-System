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
  const [originalData, setOriginalData] = useState({});
  const [actualPassword, setActualPassword] = useState('');
  const [profileImage, setProfileImage] = useState(null);
  const [isSaveDisabled, setIsSaveDisabled] = useState(true);
  const [loading, setLoading] = useState(false);
  const [saveLoading, setSaveLoading] = useState(false);
  const [passwordUpdated, setPasswordUpdated] = useState(false);
  const [imageUpdateLoading, setImageUpdateLoading] = useState(false);

  /** Load user profile from backend **/
  const loadUserProfile = useCallback(async () => {
    try {
      setLoading(true);
      const token = localStorage.getItem('authToken') || localStorage.getItem('token');
      if (!token) {
        navigate('/signin');
        return;
      }

      const response = await API.get('/api/users/profile');
      const data = response.data;
      const userProfile = data.data || data;

      let mobile = userProfile.phone || '';
      const countryCode = '+94';
      if (mobile.startsWith(countryCode)) mobile = mobile.slice(countryCode.length);

      const newUserData = {
        name: userProfile.name || '',
        email: userProfile.email || '',
        mobile,
        countryCode,
        password: '',
        confirmPassword: '',
        newPassword: '',
        currentPassword: '',
      };

      setUserData(newUserData);
      setOriginalData(newUserData);

      if (userProfile.profile_picture) {
        // Add proper prefix for Base64
        const lowerCase = userProfile.profile_picture.substring(0, 10).toLowerCase();
        let prefix = 'data:image/jpeg;base64,';
        if (lowerCase.includes('png')) prefix = 'data:image/png;base64,';
        else if (lowerCase.includes('jpg')) prefix = 'data:image/jpeg;base64,';
        else if (lowerCase.includes('jpeg')) prefix = 'data:image/jpeg;base64,';

        setProfileImage(
          userProfile.profile_picture.startsWith('data:')
            ? userProfile.profile_picture
            : `${prefix}${userProfile.profile_picture}`
        );
      } else {
        setProfileImage(null);
      }

      setActualPassword('********');
      setPasswordUpdated(false);
    } catch (error) {
      console.error('Profile load error:', error);
      if (error.response?.status === 401) {
        localStorage.removeItem('authToken');
        localStorage.removeItem('token');
        navigate('/signin');
      } else {
        alert('Failed to load profile: ' + (error.response?.data?.detail || 'Network error'));
      }
    } finally {
      setLoading(false);
    }
  }, [navigate]);

  useEffect(() => {
    loadUserProfile();
  }, [loadUserProfile]);

  const handleInputChange = (name, value) => {
    setUserData(prev => ({ ...prev, [name]: value }));
  };

  const handleEditClick = () => {
    setOriginalData({ ...userData });
    setIsEditing(true);
    setPasswordUpdated(false);
  };

  const handleCancelClick = () => {
    setUserData({ ...originalData });
    setIsEditing(false);
    setIsSaveDisabled(true);
    setPasswordUpdated(false);
  };

  /** Convert file to Base64 **/
  const fileToBase64 = (file) => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = () => resolve(reader.result); // full data:image/... string
      reader.onerror = reject;
    });
  };

  /** Compress image to max 150x150 (optional) **/
  const compressImage = (file) => {
    return new Promise((resolve, reject) => {
      const img = new Image();
      const objectUrl = URL.createObjectURL(file);

      img.onload = () => {
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');

        const maxSize = 150;
        let { width, height } = img;

        if (width > height && width > maxSize) {
          height = Math.round((height * maxSize) / width);
          width = maxSize;
        } else if (height >= width && height > maxSize) {
          width = Math.round((width * maxSize) / height);
          height = maxSize;
        }

        canvas.width = width;
        canvas.height = height;
        ctx.drawImage(img, 0, 0, width, height);

        canvas.toBlob(
          (blob) => {
            if (blob) resolve(blob);
            else reject(new Error('Canvas toBlob failed'));
          },
          'image/jpeg',
          0.6
        );

        URL.revokeObjectURL(objectUrl);
      };

      img.onerror = () => {
        URL.revokeObjectURL(objectUrl);
        reject(new Error('Image load failed'));
      };

      img.src = objectUrl;
    });
  };

  /** Handle profile image update **/
  const handleImageChange = async (file) => {
    try {
      setImageUpdateLoading(true);

      // Compress if large
      let processedFile = file;
      if (file.size >= 50000) {
        const blob = await compressImage(file);
        processedFile = new File([blob], file.name, { type: file.type });
      }

      // Convert to Base64
      let base64Data = await fileToBase64(processedFile); // full data:image/... string
      setProfileImage(base64Data);

      // Remove prefix before sending to backend (just the base64 text)
      const base64Text = base64Data.split(',')[1];

      const response = await API.put('/api/users/profile/update-picture-base64', {
        profile_picture: base64Text,
      });

      if (response.data.success) {
        alert('Profile picture updated successfully!');
        await loadUserProfile();
      } else {
        throw new Error(response.data.message || 'Upload failed');
      }
    } catch (error) {
      console.error('Profile pic upload error:', error);
      alert('Failed to upload profile picture. Try a smaller image.');
      await loadUserProfile();
    } finally {
      setImageUpdateLoading(false);
    }
  };

  /** Remove profile picture **/
  const handleRemovePhoto = async () => {
    try {
      setImageUpdateLoading(true);
      const response = await API.put('/api/users/profile/update-picture-base64', {
        profile_picture: '',
      });
      if (response.data.success) {
        setProfileImage(null);
        alert('Profile picture removed successfully!');
        await loadUserProfile();
      } else {
        throw new Error('Failed to remove picture');
      }
    } catch (error) {
      console.error('Remove photo error:', error);
      alert('Failed to remove profile picture.');
    } finally {
      setImageUpdateLoading(false);
    }
  };

  /** Save profile updates **/
  const handleSave = async () => {
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!userData.name.trim()) return alert('Name cannot be empty.');
    if (!emailPattern.test(userData.email)) return alert('Enter a valid email.');
    if (!/^\d{9}$/.test(userData.mobile)) return alert('Mobile must be 9 digits.');
    if (userData.newPassword && userData.newPassword !== userData.confirmPassword)
      return alert('Password mismatch.');

    try {
      setSaveLoading(true);
      const payload = {
        name: userData.name.trim(),
        email: userData.email.trim(),
        phone: `${userData.countryCode}${userData.mobile}`,
        ...(userData.newPassword ? { password: userData.newPassword } : {}),
      };

      const response = await API.put('/api/users/profile/update', payload);

      if (response.data.success) {
        await loadUserProfile();
        setIsEditing(false);
        setIsSaveDisabled(true);
        if (userData.newPassword) setPasswordUpdated(true);
        alert('Profile updated successfully!');
      } else {
        throw new Error(response.data.message || 'Update failed');
      }
    } catch (error) {
      console.error('Profile save error:', error);
      alert(error.response?.data?.detail || error.message || 'Failed to update profile.');
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
              onImageChange={handleImageChange}
              onRemovePhoto={handleRemovePhoto}
              loading={imageUpdateLoading}
            />

            <div className="profile-info-container">
              <UserIdentity name={userData.name} isEditing={isEditing} />

              <ProfileInfoSection
                userData={userData}
                isEditing={isEditing}
                onInputChange={handleInputChange}
                actualPassword={actualPassword}
                maskPassword={maskPassword}
                passwordUpdated={passwordUpdated}
                onValidationChange={setIsSaveDisabled}
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
