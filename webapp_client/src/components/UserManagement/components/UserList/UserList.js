import React from 'react';
import './UserList.css';
import { DeleteIcon, EditIcon } from '../../../Icons/Icons';

const UserList = ({
    users,
    onStatusChange,
    onDeleteUser,
    onEditUser = () => {} // Default no-op function
}) => {
    // Get initials for avatar placeholder
    const getInitials = (name) => {
        return name
            .split(' ')
            .map(word => word[0])
            .join('')
            .toUpperCase();
    };

    // Format date safely
    const formatDate = (dateString) => {
        if (!dateString) return "N/A";

        const date = new Date(dateString);
        if (!(date instanceof Date) || isNaN(date.getTime())) return "N/A";

        return date.toLocaleDateString(undefined, {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
        });
    };



    // Calculate "time ago"
    const getTimeAgo = (dateString) => {
        if (!dateString) return "";
        const joinDate = new Date(dateString);
        if (isNaN(joinDate)) return "";
        const now = new Date();
        const diffInMs = now - joinDate;
        const diffInDays = Math.floor(diffInMs / (1000 * 60 * 60 * 24));

        if (diffInDays === 0) return 'Today';
        if (diffInDays === 1) return 'Yesterday';
        if (diffInDays < 7) return `${diffInDays} days ago`;
        if (diffInDays < 30) return `${Math.floor(diffInDays / 7)} weeks ago`;
        return `${Math.floor(diffInDays / 30)} months ago`;
    };

    return (
        <div className="user-list-container">
            <div className="user-list-header">
                <h3>Registered Users ({users.length})</h3>
            </div>

            {users.length > 0 ? (
                <div className="user-list">
                    {users.map(user => (
                        <div key={user.id || user.user_id} className="user-list-item">
                            <div className="user-avatar-container">
                                {user.profilePicture ? (
                                    <img
                                        src={user.profilePicture}
                                        alt={user.name}
                                        className="user-avatar"
                                    />
                                ) : (
                                    <div className="user-avatar-placeholder">
                                        {getInitials(user.name)}
                                    </div>
                                )}
                            </div>

                            <div className="user-content">
                                <div className="user-main-info">
                                    <h4 className="user-name">{user.name}</h4>
                                    <span className={`user-status status-${user.status}`}>
                                        {user.status === 'active' ? 'Active' : 'Inactive'}
                                    </span>
                                </div>

                                <div className="user-details">
                                    <p className="user-email">{user.email}</p>
                                    <p className="user-phone">{user.phone}</p>
                                </div>

                                <div className="user-meta">
                                    <span className="user-role">{user.role}</span>
                                    <span className="user-join-date">
                                        Joined {formatDate(user.joinDate)} • {getTimeAgo(user.joinDate)}
                                    </span>
                                </div>

                                <div className="user-actions">
                                    <button
                                        className="btn-action btn-edit"
                                        onClick={() => onEditUser(user)}
                                    >
                                        <EditIcon />Edit
                                    </button>

                                    <button
                                        className="btn-action btn-status"
                                        onClick={() =>
                                            onStatusChange(
                                                user.id || user.user_id,
                                                user.status === 'active' ? 'inactive' : 'active'
                                            )
                                        }
                                    >
                                        {user.status === 'active' ? 'Deactivate' : 'Activate'}
                                    </button>

                                    <button
                                        className="btn-action btn-delete"
                                        onClick={() => onDeleteUser(user.id || user.user_id)}
                                    >
                                        <DeleteIcon />Delete
                                    </button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            ) : (
                <div className="no-users">
                    <p>No users found matching your criteria</p>
                </div>
            )}
        </div>
    );
};

export default UserList;
