import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './Notifications.css';
import NotificationsList from './components/NotificationsList/NotificationsList';
import HeaderPages from '../Common/HeaderPages';
import notificationsData from '../../data/notificationsData';
import API from '../../api/axios';

const Notifications = () => {
  const navigate = useNavigate();
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);

  // Fetch notifications from backend
  useEffect(() => {
    const fetchNotifications = async () => {
      try {
        const response = await API.get('/api/notifications/'); // Updated to match backend
        // Transform backend response to frontend structure
        const backendData = response.data.map((notif) => ({
          id: notif.id,
          type: notif.type,
          title: notif.type === 'cancellation' ? 'Cancellation Request' :
                 notif.type === 'security' ? 'Security Alert' : 'Notification',
          content: notif.message,
          time: new Date(notif.created_at).toLocaleString(undefined, {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
          }),
          read: notif.status === 'read',
          action: notif.type === 'cancellation' ? 'Approve' :
                  notif.type === 'security' ? 'View Logs' : null,
        }));
        setNotifications(backendData);
      } catch (error) {
        console.error('Failed to fetch notifications, using mock data', error);
        setNotifications(notificationsData); // fallback
      } finally {
        setLoading(false);
      }
    };

    fetchNotifications();
  }, []);

  const markAsRead = async (id) => {
    setNotifications(prev =>
      prev.map(notification =>
        notification.id === id ? { ...notification, read: true } : notification
      )
    );

    // Send request to backend
    try {
      await API.post(`/api/notifications/${id}/read`);
    } catch (error) {
      console.error('Failed to mark notification as read', error);
    }
  };

  const performAction = (notification) => {
    switch(notification.type) {
      case 'cancellation':
        console.log('Approving cancellation:', notification.id);
        break;
      case 'security':
        console.log('Viewing logs for security alert:', notification.id);
        break;
      default:
        console.log('Performing default action for:', notification.id);
    }
    markAsRead(notification.id);
  };

  const handleBackToDashboard = () => {
    navigate('/dashboard');
  };

  if (loading) return <p>Loading notifications...</p>;

  return (
    <div className="notifications-page">
      <HeaderPages
        title="Notifications"
        onBack={handleBackToDashboard}
      />
      <NotificationsList 
        notifications={notifications} 
        onMarkAsRead={markAsRead}
        onPerformAction={performAction}
      />
    </div>
  );
};

export default Notifications;
