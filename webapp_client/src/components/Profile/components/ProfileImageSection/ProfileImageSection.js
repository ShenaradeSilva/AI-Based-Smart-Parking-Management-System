import React, { useRef, useState } from 'react';
import { UploadPicIcon } from "../../../Icons/Icons"
import './ProfileImageSection.css';

const ProfileImageSection = ({ profileImage, isEditing, onImageChange, onRemovePhoto, loading }) => {
  const fileInputRef = useRef(null);
  const [imageError, setImageError] = useState('');

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    // Enhanced validation
    const error = validateImageFile(file);
    if (error) {
      setImageError(error);
      e.target.value = '';
      return;
    }

    // Strict size validation (2MB max)
    if (file.size > 2 * 1024 * 1024) {
      setImageError('Image size must be less than 2MB');
      e.target.value = '';
      return;
    }

    setImageError('');
    onImageChange(file);
    e.target.value = ''; // Reset input
  };

  const validateImageFile = (file) => {
    if (!file) return 'No file selected';
    
    const validTypes = ['image/jpeg', 'image/jpg', 'image/png'];
    if (!validTypes.includes(file.type)) {
      return 'Please select a JPEG or PNG image file only';
    }
    
    const maxSize = 2 * 1024 * 1024;
    if (file.size > maxSize) {
      return 'Image size must be less than 2MB';
    }
    
    if (file.size === 0) {
      return 'File appears to be empty';
    }
    
    return null;
  };

  const triggerFileInput = () => {
    if (!loading) {
      fileInputRef.current.click();
    }
  };

  const handleRemoveClick = () => {
    if (!loading && window.confirm('Are you sure you want to remove your profile picture?')) {
      onRemovePhoto();
    }
  };

  return (
    <div className="profile-image-section">
      <div className={`profile-image-container ${loading ? 'loading' : ''}`}>
        {loading ? (
          <div className="profile-image-loading">
            <div className="loading-text">Uploading...</div>
          </div>
        ) : profileImage ? (
          <img 
            src={profileImage} 
            alt="Profile" 
            className="profile-image"
            onError={(e) => {
              console.error('Error loading profile image');
              e.target.style.display = 'none';
            }}
          />
        ) : (
          <div className="profile-empty">
            <UploadPicIcon />
          </div>
        )}
        
        {/* Show overlay only when not loading and when editing */}
        {!loading && isEditing && (
          <div className="image-overlay" onClick={triggerFileInput}>
            <span className="camera-icon">
              <UploadPicIcon />
            </span>
          </div>
        )}
        
        <input
          type="file"
          ref={fileInputRef}
          onChange={handleImageChange}
          accept=".jpg,.jpeg,.png,image/jpeg,image/png"
          style={{ display: 'none' }}
          disabled={loading}
        />
      </div>

      {imageError && <p className="image-error-text">{imageError}</p>}

      {/* Show image actions only when not loading and when editing */}
      {!loading && isEditing && (
        <>
          <p className="change-photo-text" onClick={triggerFileInput}>
            Change Photo
          </p>

          {profileImage && (
            <p className="remove-photo-text" onClick={handleRemoveClick}>
              Remove Photo
            </p>
          )}
        </>
      )}

      {/* Help text about image requirements */}
      {isEditing && (
        <p className="image-help-text">
          Recommended: JPEG/PNG under 2MB. Image will be compressed for optimal performance.
        </p>
      )}
    </div>
  );
};

export default ProfileImageSection;