import React from 'react';
import './UserIdentity.css';

const UserIdentity = ({ name }) => {
  return (
    <div className="user-identity">
      <h2>{name || 'Your Name'}</h2>
      <p className="user-role">Admin</p>
    </div>
  );
};

export default UserIdentity;