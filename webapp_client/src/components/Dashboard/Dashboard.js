import React, { useState, useEffect } from "react";
import { useNavigate, useLocation, Routes, Route } from "react-router-dom";
import API from "../../api/axios";
import "./Dashboard.css";
import Sidebar from "./components/Sidebar/Sidebar";
import HeaderPages from "../Common/HeaderPages";
import MainContent from "./components/MainContent/MainContent";
import RegisteredVehiclesModal from "./components/Modals/RegisteredVehiclesModal";
import OccupancyReport from "./components/Modals/OccupancyReport";
import QRScanner from "../QRScanner/QRScanner";
import ParkingSlotManagement from "../ParkingSlotManagement/ParkingSlotManagement";
import CancellationRequests from "../CancellationRequests/CancellationRequests";
import WaitListManagement from "../WaitListManagement/WaitListManagement";
import Analytics from "../Analytics/Analytics";
import PeakTimeAnalysis from "../PeakTimeAnalysis/PeakTimeAnalysis";
import VehicleVisitFrequency from "../VehicleVisitFrequency/VehicleVisitFrequency";
import Bookings from "../Bookings/Bookings";
import VehicleManagement from "../VehicleManagement/VehicleManagement";
import Notifications from "../Notifications/Notifications";
import Profile from "../Profile/Profile";
import UserManagement from "../UserManagement/UserManagement";
import notificationsDataMock from "../../data/notificationsData";
import vehiclesDataMock from "../../data/vehiclesData";

// Fallback dashboard data
const dashboardDataFallback = {
  registeredVehicles: vehiclesDataMock.length,
  occupancyRate: 77,
  uptimeStatus: "Online",
  bookings: 50,
  occupiedSlots: 100,
  availableSlots: 35,
  alerts: 5,
};

const Dashboard = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [activeSection, setActiveSection] = useState("dashboard");
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [showVehiclesModal, setShowVehiclesModal] = useState(false);
  const [showOccupancyReport, setShowOccupancyReport] = useState(false);

  const [dashboardData, setDashboardData] = useState(dashboardDataFallback);
  const [notifications, setNotifications] = useState(notificationsDataMock);

  // Authentication check
  useEffect(() => {
    const token = localStorage.getItem("authToken");
    if (!token) navigate("/signin");
    else setIsAuthenticated(true);
  }, [navigate]);

  // Active section based on URL
  useEffect(() => {
    const path = location.pathname;
    if (path.includes("/analytics-vehicle")) setActiveSection("analytics-vehicle");
    else if (path.includes("/analytics-peak-time")) setActiveSection("analytics-peak");
    else if (path.includes("/analytics")) setActiveSection("analytics");
    else if (path.includes("/qr-scanner")) setActiveSection("qr-scanner");
    else if (path.includes("/bookings")) setActiveSection("bookings");
    else if (path.includes("/vehicle-management")) setActiveSection("vehicle-management");
    else if (path.includes("/manage-parking")) setActiveSection("manage-parking");
    else if (path.includes("/manage-waitlist")) setActiveSection("manage-waitlist");
    else if (path.includes("/manage-cancellation")) setActiveSection("manage-cancellation");
    else if (path.includes("/notifications")) setActiveSection("notifications");
    else if (path.includes("/profile")) setActiveSection("profile");
    else if (path.includes("/user-management")) setActiveSection("user-management");
    else if (path === "/dashboard") setActiveSection("dashboard");
  }, [location]);

  // Fetch dashboard & notifications
  useEffect(() => {
    const fetchDashboardData = async () => {
      try {
        const res = await API.get("/api/dashboard/");
        if (res.status === 200 && res.data) setDashboardData(res.data);
        else setDashboardData(dashboardDataFallback);
      } catch (err) {
        console.warn("Failed to fetch dashboard data, using fallback.", err);
        setDashboardData(dashboardDataFallback);
      }
    };

    const fetchNotifications = async () => {
      try {
        const res = await API.get("/api/notifications/");
        if (res.status === 200 && res.data) {
          // FIXED notification time formatting
          const mapped = res.data.map((notif) => {
            const createdAt = new Date(notif.created_at);
            const formattedTime = new Date(notif.created_at).toLocaleString(undefined, {
              year: "numeric",
              month: "short",
              day: "2-digit",
              hour: "2-digit",
              minute: "2-digit",
              second: "2-digit",
              hour12: true,
              timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone, // ensures local
            });


            return {
              id: notif.notification_id,
              type: notif.type,
              title:
                notif.type === "cancellation"
                  ? "Cancellation Request"
                  : notif.type === "security"
                  ? "Security Alert"
                  : "Notification",
              content: notif.message,
              time: formattedTime, //Consistent & readable format
              read: notif.status === "read",
            };
          });
          setNotifications(mapped);
        } else {
          setNotifications(notificationsDataMock);
        }
      } catch (err) {
        console.warn("Failed to fetch notifications, using fallback.", err);
        setNotifications(notificationsDataMock);
      }
    };

    fetchDashboardData();
    fetchNotifications();
  }, []);

  // Handlers-
  const handleViewVehicles = () => setShowVehiclesModal(true);
  const handleViewOccupancyReport = () => setShowOccupancyReport(true);

  if (!isAuthenticated) return null;

  return (
    <div className="dashboard">
      <Sidebar
        activeSection={activeSection}
        setActiveSection={setActiveSection}
        navigate={navigate}
      />

      <div className="dashboard-main">
        <Routes>
          <Route
            path="/"
            element={
              <>
                <HeaderPages
                  title="Dashboard"
                  notifications={notifications}
                  showNotifications
                  showProfileMenu
                />
                <MainContent
                  dashboardData={dashboardData}
                  onViewDrivers={handleViewVehicles}
                  onViewOccupancyReport={handleViewOccupancyReport}
                  navigate={navigate}
                  notifications={notifications}
                />
              </>
            }
          />
          <Route path="qr-scanner" element={<QRScanner />} />
          <Route path="bookings/*" element={<Bookings />} />
          <Route path="vehicle-management" element={<VehicleManagement />} />
          <Route path="manage-parking" element={<ParkingSlotManagement />} />
          <Route path="manage-waitlist" element={<WaitListManagement />} />
          <Route path="manage-cancellation" element={<CancellationRequests />} />
          <Route path="analytics" element={<Analytics />} />
          <Route path="analytics-peak-time" element={<PeakTimeAnalysis />} />
          <Route path="analytics-vehicle" element={<VehicleVisitFrequency />} />
          <Route path="notifications" element={<Notifications />} />
          <Route path="profile" element={<Profile />} />
          <Route path="user-management" element={<UserManagement />} />
        </Routes>
      </div>

      {showVehiclesModal && (
        <RegisteredVehiclesModal
          onClose={() => setShowVehiclesModal(false)}
          vehicleCount={dashboardData.registeredVehicles}
        />
      )}

      {showOccupancyReport && (
        <OccupancyReport
          onClose={() => setShowOccupancyReport(false)}
          occupancyRate={dashboardData.occupancyRate}
        />
      )}
    </div>
  );
};

export default Dashboard;
