import React, { useRef, useState } from 'react';
import { UploadPicIcon } from '../../../Icons/Icons';
import { validateImageFile } from '../../../../utils/validations';
import './ProfileImageSection.css';

const ProfileImageSection = ({ profileImage, isEditing, onImageChange, onRemovePhoto }) => {
  const fileInputRef = useRef(null);
  const [imageError, setImageError] = useState('');

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      const error = validateImageFile(file);
      if (error) {
        setImageError(error);
        e.target.value = '';
        return;
      }

      setImageError('');

      const reader = new FileReader();
      reader.onload = (e) => {
        onImageChange(e.target.result);
      };
      reader.readAsDataURL(file);
    }
  };

  const triggerFileInput = () => {
    fileInputRef.current.click();
  };

  return (
    <div className="profile-image-section">
      <div className="profile-image-container">
        {profileImage ? (
          <img 
            src={profileImage} 
            alt="Profile" 
            className="profile-image"
          />
        ) : (
          <div className="profile-empty"></div>
        )}
        <div className="image-overlay" onClick={triggerFileInput}>
          <span className="camera-icon">
            <UploadPicIcon />
          </span>
        </div>
        <input
          type="file"
          ref={fileInputRef}
          onChange={handleImageChange}
          accept=".jpg,.jpeg,.png,.gif"
          style={{ display: 'none' }}
        />
      </div>

      {imageError && <p className="image-error-text">{imageError}</p>}

      <p className="change-photo-text" onClick={triggerFileInput}>
        Change Photo
      </p>

      {isEditing && profileImage && (
        <p className="remove-photo-text" onClick={onRemovePhoto}>
          Remove Photo
        </p>
      )}
    </div>
  );
};

export default ProfileImageSection;