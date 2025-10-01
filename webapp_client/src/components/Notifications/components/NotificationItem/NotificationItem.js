import React from 'react';
import { CloseIcon } from '../../../Icons/Icons';
import './NotificationItem.css';

const NotificationItem = ({ notification, onMarkAsRead, onPerformAction }) => {
  const isRead = notification.read; // use mapped field
  return (
    <div 
      className={`notification-item ${notification.type} ${isRead ? 'read' : 'unread'}`}
    >
      <div className="notification-header">
        <h3>{notification.title}</h3>
        <span className="notification-time">{notification.time}</span>
      </div>
      
      <div className="notification-content">
        <p>{notification.content}</p>
      </div>
      
      {notification.action && !isRead && (
        <div className="notification-footer">
          <button 
            className="notification-action"
            onClick={() => onPerformAction(notification)}
          >
            {notification.action}
          </button>
        </div>
      )}
      
      {!isRead && (
        <div 
          className="mark-read"
          onClick={() => onMarkAsRead(notification.id)}
          title="Mark as read"
        >
          <CloseIcon />
        </div>
      )}
    </div>
  );
};


export default NotificationItem;
