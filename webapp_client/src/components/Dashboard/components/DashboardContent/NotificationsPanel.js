import React, { useEffect, useState } from 'react';
import API from '../../../../api/axios'; // your axios instance
import './NotificationsPanel.css';

const NotificationsPanel = () => {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchNotifications = async () => {
      try {
        const token = localStorage.getItem('authToken'); // ensure user is logged in
        if (!token) throw new Error('No auth token found');

        const res = await API.get('/api/notifications/fetch', {
          headers: {
            Authorization: `Bearer ${token}`
          }
        });

        setNotifications(res.data);
      } catch (err) {
        console.error('Failed to fetch notifications', err);
        setError('Failed to load notifications.');
      } finally {
        setLoading(false);
      }
    };

    fetchNotifications();
  }, []);

  const latestNotifications = notifications.slice(0, 5);

  if (loading) return <p>Loading notifications...</p>;
  if (error) return <p className="error">{error}</p>;

  return (
    <div className="notifications-panel">
      <h3>Notifications</h3>
      {latestNotifications.length === 0 ? (
        <p className="no-notifications">No notifications yet</p>
      ) : (
        <ul>
          {latestNotifications.map((notif) => {
            const displayTitle = notif.title === 'Notification' ? '' : notif.title;
            return (
              <li
                key={notif.id}
                className={`notification ${notif.type} ${notif.status === 'read' ? 'read' : 'unread'}`}
              >
                <div className="notification-content">
                  {displayTitle && <span className="notification-title">{displayTitle}</span>}
                  <span className="notification-text">{notif.message}</span>
                  <span className="notification-time">{new Date(notif.created_at).toLocaleString()}</span>
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
