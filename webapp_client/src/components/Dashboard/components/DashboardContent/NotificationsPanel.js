import React from 'react';
import './NotificationsPanel.css';

const NotificationsPanel = ({ notifications }) => {
  // Show only the latest 5 notifications
  const latestNotifications = notifications.slice(0, 5);

  return (
    <div className="notifications-panel">
      <h3>Notifications</h3>
      {latestNotifications.length === 0 ? (
        <p className="no-notifications">No notifications yet</p>
      ) : (
        <ul>
          {latestNotifications.map((notif) => {
            // Remove generic "Notification" title
            const displayTitle =
              notif.title === 'Notification' ? '' : notif.title;

            return (
              <li
                key={notif.id}
                className={`notification ${notif.type} ${notif.read ? 'read' : 'unread'}`}
              >
                <div className="notification-content">
                  {displayTitle && (
                    <span className="notification-title">{displayTitle}</span>
                  )}
                  <span className="notification-text">{notif.content}</span>
                  <span className="notification-time">{notif.time}</span>
                </div>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
};

export default NotificationsPanel;
