// File: src/components/Common/HeaderPages.js
import React, { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { BackArrow, NotificationIcon, ProfileIcon } from "../Icons/Icons";
import "./HeaderPages.css";

const HeaderPages = ({
  title,
  subtitle,
  onBack,
  backTo = "/dashboard",
  level = "h1",
  notifications = [],
  showNotifications = false,
  showProfileMenu = false
}) => {
  const navigate = useNavigate();
  const HeadingTag = level;

  const [profileMenuOpen, setProfileMenuOpen] = useState(false);
  const [notifData, setNotifData] = useState(notifications);
  const [unreadCount, setUnreadCount] = useState(0);

  // Update unread count
  useEffect(() => {
    const count = notifData.filter((n) => !n.read).length;
    setUnreadCount(count);
  }, [notifData]);

  const handleBack = () => {
    if (onBack) onBack();
    else navigate(backTo);
  };

  const toggleProfileMenu = () => setProfileMenuOpen(!profileMenuOpen);

  const handleProfileClick = () => {
    setProfileMenuOpen(false);
    navigate("/dashboard/profile");
  };

  const handleLogout = () => {
    localStorage.removeItem("authToken");
    navigate("/signin");
  };

  const handleNotificationsClick = () => {
    // mark all as read
    setNotifData(notifData.map((n) => ({ ...n, read: true })));
    navigate("/dashboard/notifications");
  };

  return (
    <div className="page-header dashboard-header">
      {backTo && (
        <button className="back-button-icon" onClick={handleBack} title="Back">
          <BackArrow />
        </button>
      )}

      <div className="header-title">
        <HeadingTag>{title}</HeadingTag>
        {subtitle && <span className="header-subtitle">{subtitle}</span>}
      </div>

      <div className="header-actions">
        {showNotifications && (
          <div className="notifications" onClick={handleNotificationsClick}>
            <div className="icon-wrapper">
              <NotificationIcon />
              {unreadCount > 0 && (
                <div className="notification-count">{unreadCount}</div>
              )}
            </div>
          </div>
        )}

        {showProfileMenu && (
          <div className="profile-menu-container">
            <div className="profile-icon" onClick={toggleProfileMenu}>
              <ProfileIcon />
            </div>
            {profileMenuOpen && (
              <div className="profile-dropdown">
                <div className="dropdown-item" onClick={handleProfileClick}>
                  My Profile
                </div>
                <div className="dropdown-item" onClick={handleLogout}>
                  Logout
                </div>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default HeaderPages;
