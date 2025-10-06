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
        const response = await API.get('/api/notifications/fetch');
        console.log('=== BACKEND RESPONSE ===');
        console.log('Raw backend data:', response.data);
        
        // Check the structure of the first notification
        if (response.data.length > 0) {
          console.log('First notification structure:', response.data[0]);
          console.log('Available fields:', Object.keys(response.data[0]));
        }
        
        // Transform backend response to frontend structure
        const backendData = response.data.map((notif) => {
          // Try different possible ID fields
          const notificationId = notif.notification_id || notif.id || notif.notificationId;
          console.log(`Processing notification - raw ID fields:`, {
            notification_id: notif.notification_id,
            id: notif.id,
            notificationId: notif.notificationId,
            finalId: notificationId
          });
          
          return {
            id: notificationId, // Use whatever ID field exists
            type: notif.type,
            title: notif.type === 'cancellation' ? 'Cancellation Request' :
                   notif.type === 'security' ? 'Security Alert' : 
                   notif.type === 'success' ? 'Success' : 'Notification',
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
          };
        });
        
        console.log('=== TRANSFORMED NOTIFICATIONS ===');
        console.log('Final notifications data:', backendData);
        setNotifications(backendData);
      } catch (error) {
        console.error('Failed to fetch notifications, using mock data', error);
        // Use mock data as fallback
        setNotifications(notificationsData);
      } finally {
        setLoading(false);
      }
    };

    fetchNotifications();
  }, []);

  const markAsRead = async (id) => {
    console.log('=== MARK AS READ CALLED ===');
    console.log('Received ID:', id);
    console.log('Type of ID:', typeof id);
    
    if (!id || id === 'undefined') {
      console.error('Invalid notification ID:', id);
      alert(`Cannot mark as read: Invalid notification ID (${id})`);
      return;
    }

    // First update UI optimistically
    setNotifications(prev =>
      prev.map(notification =>
        notification.id === id ? { ...notification, read: true } : notification
      )
    );

    // Send request to backend
    try {
      console.log(`Making API call to: /api/notifications/${id}/read`);
      await API.post(`/api/notifications/${id}/read`);
      console.log('Successfully marked notification as read on backend');
    } catch (error) {
      console.error('Failed to mark notification as read', error);
      // Revert UI if failed
      setNotifications(prev =>
        prev.map(notification =>
          notification.id === id ? { ...notification, read: false } : notification
        )
      );
      alert('Failed to mark notification as read. Please try again.');
    }
  };

  const performAction = (notification) => {
    console.log('=== PERFORM ACTION CALLED ===');
    console.log('Notification:', notification);
    
    if (!notification.id || notification.id === 'undefined') {
      console.error('Invalid notification ID in performAction');
      return;
    }

    switch(notification.type) {
      case 'cancellation':
        console.log('Approving cancellation:', notification.id);
        // Add your cancellation approval logic here
        break;
      case 'security':
        console.log('Viewing logs for security alert:', notification.id);
        // Add your security logs logic here
        break;
      default:
        console.log('Performing default action for:', notification.id);
    }
    markAsRead(notification.id);
  };

  const handleBackToDashboard = () => {
    navigate('/dashboard');
  };

  if (loading) return <div className="loading">Loading notifications...</div>;

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