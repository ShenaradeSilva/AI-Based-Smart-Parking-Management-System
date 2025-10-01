import React from 'react';
import NotificationItem from '../NotificationItem/NotificationItem';
import NoNotifications from '../NoNotifications/NoNotifications';
import './NotificationsList.css';

const NotificationsList = ({ notifications, onMarkAsRead, onPerformAction }) => {
  if (!notifications || notifications.length === 0) {
    return <NoNotifications />;
  }

  return (
    <div className="notifications-list">
      {notifications.map(notification => (
        <NotificationItem
          key={notification.id}
          notification={notification}
          onMarkAsRead={onMarkAsRead}
          onPerformAction={onPerformAction}
        />
      ))}
    </div>
  );
};

export default NotificationsList;