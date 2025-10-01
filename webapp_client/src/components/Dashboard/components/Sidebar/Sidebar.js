import React, { useState } from 'react';
import { Logo1 } from '../../../Logos/Logos';
import { DropdownArrow } from '../../../Icons/Icons';
import './Sidebar.css';

const Sidebar = ({ activeSection, setActiveSection, navigate }) => {
  const [showManageBookingsMenu, setShowManageBookingsMenu] = useState(false);
  const [showManageSlotsMenu, setShowManageSlotsMenu] = useState(false);
  const [showAnalyticsMenu, setShowAnalyticsMenu] = useState(false);

  const isManageBookingsMenuActive = () => {
    return ['bookings', 'vehicle-management'].includes(activeSection);
  };

  const isManageSlotsMenuActive = () => {
    return ['manage-parking', 'manage-waitlist', 'manage-cancellation'].includes(activeSection);
  };

  const isAnalyticsMenuActive = () => {
    return ['analytics', 'analytics-peak', 'analytics-vehicle'].includes(activeSection);
  };

  const toggleManageBookingsMenu = () => {
    setShowManageBookingsMenu(!showManageBookingsMenu);
    if (showManageBookingsMenu) setShowManageBookingsMenu(false);
  };

  const toggleManageSlotsMenu = () => {
    setShowManageSlotsMenu(!showManageSlotsMenu);
    if (showManageSlotsMenu) setShowManageSlotsMenu(false);
  };

  const toggleAnalyticsMenu = () => {
    setShowAnalyticsMenu(!showAnalyticsMenu);
    if (showAnalyticsMenu) setShowAnalyticsMenu(false);
  };

  const handleMenuItemClick = (section, path = null) => {
    setActiveSection(section);
    if (section.startsWith('manage-bookings-')) setShowManageBookingsMenu(false);
    if (section.startsWith('manage-slots-')) setShowManageSlotsMenu(false);
    if (section.startsWith('analytics-')) setShowAnalyticsMenu(false);
    if (path) navigate(path);
  };

  return (
    <div className="dashboard-sidebar">
      <div className="sidebar-header">
        <div className="logo-container">
          <Logo1 />
        </div>
        <h2>ParkFlow</h2>
      </div>

      <div className="sidebar-menu">
        <div className="menu-section">
          <ul>
            <li
              className={activeSection === 'dashboard' ? 'active' : ''}
              onClick={() => handleMenuItemClick('dashboard', '/dashboard')}
            >
              Dashboard
            </li>

            <li
              className={activeSection === 'qr-scanner' ? 'active' : ''}
              onClick={() => handleMenuItemClick('qr-scanner', '/dashboard/qr-scanner')}
            >
              QR Scanner
            </li>

            <li className={`menu-item-with-dropdown ${isManageBookingsMenuActive() ? 'active-parent' : ''}`}>
              <div className="dropdown-toggle" onClick={toggleManageBookingsMenu}>
                Manage Bookings
                <DropdownArrow isOpen={showManageBookingsMenu} />
              </div>
              {showManageBookingsMenu && (
                <ul className="dropdown-menu">
                  <li
                    className={activeSection === 'bookings' ? 'active' : ''}
                    onClick={() => handleMenuItemClick('bookings', '/dashboard/bookings')}
                  >
                    Bookings
                  </li>

                  <li
                    className={activeSection === 'vehicle-management' ? 'active' : ''}
                    onClick={() => handleMenuItemClick('vehicle-management', '/dashboard/vehicle-management')}
                  >
                    Vehicle Management
                  </li>
                </ul>
              )}
            </li>


            <li className={`menu-item-with-dropdown ${isManageSlotsMenuActive() ? 'active-parent' : ''}`}>
              <div className="dropdown-toggle" onClick={toggleManageSlotsMenu}>
                Manage Slots
                <DropdownArrow isOpen={showManageSlotsMenu} />
              </div>
              {showManageSlotsMenu && (
                <ul className="dropdown-menu">
                  <li
                    className={activeSection === 'manage-parking' ? 'active' : ''}
                    onClick={() => handleMenuItemClick('manage-parking', '/dashboard/manage-parking')}
                  >
                    Parking Slot Management
                  </li>

                  <li
                    className={activeSection === 'manage-waitlist' ? 'active' : ''}
                    onClick={() => handleMenuItemClick('manage-waitlist', '/dashboard/manage-waitlist')}
                  >
                    Wait list Management
                  </li>

                  <li
                    className={activeSection === 'manage-cancellation' ? 'active' : ''}
                    onClick={() => handleMenuItemClick('manage-cancellation', '/dashboard/manage-cancellation')}
                  >
                    Cancellation Request
                  </li>
                </ul>
              )}
            </li>

            <li className={`menu-item-with-dropdown ${isAnalyticsMenuActive() ? 'active-parent' : ''}`}>
              <div className="dropdown-toggle" onClick={toggleAnalyticsMenu}>
                Analytics
                <DropdownArrow isOpen={showAnalyticsMenu} />
              </div>
              {showAnalyticsMenu && (
                <ul className="dropdown-menu">
                  <li
                    className={activeSection === 'analytics' ? 'active' : ''}
                    onClick={() => handleMenuItemClick('analytics', '/dashboard/analytics')}
                  >
                    Analytics Overview
                  </li>

                  <li
                    className={activeSection === 'analytics-peak' ? 'active' : ''}
                    onClick={() => handleMenuItemClick('analytics-peak', '/dashboard/analytics-peak-time')}
                  >
                    Peak Time Analysis
                  </li>
                  
                  <li
                    className={activeSection === 'analytics-vehicle' ? 'active' : ''}
                    onClick={() => handleMenuItemClick('analytics-vehicle', '/dashboard/analytics-vehicle')}
                  >
                    Vehicle Visit Frequency Analysis
                  </li>
                </ul>
              )}
            </li>

            <li
              className={activeSection === 'notifications' ? 'active' : ''}
              onClick={() => handleMenuItemClick('notifications', '/dashboard/notifications')}
            >
              Notifications
            </li>

            <li
              className={activeSection === 'profile' ? 'active' : ''}
              onClick={() => handleMenuItemClick('profile', '/dashboard/profile')}
            >
              Profile
            </li>

            <li
              className={activeSection === 'user-management' ? 'active' : ''}
              onClick={() => handleMenuItemClick('user-management', '/dashboard/user-management')}
            >
              Manage Users
            </li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default Sidebar;