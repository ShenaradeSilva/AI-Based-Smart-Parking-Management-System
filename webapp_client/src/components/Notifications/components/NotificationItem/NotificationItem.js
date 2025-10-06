import React from 'react';
import { CloseIcon } from '../../../Icons/Icons';
import './NotificationItem.css';

const NotificationItem = ({ notification, onMarkAsRead, onPerformAction }) => {
  const isRead = notification.read;

  const handleMarkAsRead = () => {
    console.log('NotificationItem - handleMarkAsRead called');
    console.log('Notification object:', notification);
    console.log('Notification ID:', notification.id);
    console.log('onMarkAsRead function:', onMarkAsRead);
    
    if (onMarkAsRead && notification.id) {
      onMarkAsRead(notification.id);
    } else {
      console.error('Cannot mark as read - missing ID or handler:', {
        id: notification.id,
        hasHandler: !!onMarkAsRead
      });
    }
  };

  const handlePerformAction = () => {
    console.log('NotificationItem - handlePerformAction called');
    console.log('Notification object:', notification);
    
    if (onPerformAction && notification.id) {
      onPerformAction(notification);
    } else {
      console.error('Cannot perform action - missing ID or handler:', {
        id: notification.id,
        hasHandler: !!onPerformAction
      });
    }
  };

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
            onClick={handlePerformAction}
          >
            {notification.action}
          </button>
        </div>
      )}
      
      {!isRead && (
        <div 
          className="mark-read"
          onClick={handleMarkAsRead}
          title="Mark as read"
        >
          <CloseIcon />
        </div>
      )}
    </div>
  );
};

export default NotificationItem;