import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import UserList from './components/UserList/UserList';
import UserFilters from './components/UserFilters/UserFilters';
import AddUserModal from './components/UserModal/AddUserModal';
import EditUserModal from './components/UserModal/EditUserModal';
import API from '../../api/axios'; // Axios instance
import './UserManagement.css';
import HeaderPages from '../Common/HeaderPages';
import { AddIcon } from '../Icons/Icons';

const UserManagement = () => {
    const navigate = useNavigate();
    const [users, setUsers] = useState([]);
    const [filteredUsers, setFilteredUsers] = useState([]);
    const [showAddModal, setShowAddModal] = useState(false);
    const [showEditModal, setShowEditModal] = useState(false);
    const [selectedUser, setSelectedUser] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');
    const [statusFilter, setStatusFilter] = useState('all');
    const [roleFilter, setRoleFilter] = useState('all');

    const handleBackToDashboard = () => navigate('/dashboard');

    // Fetch users from backend
    const fetchUsers = async () => {
        try {
            const response = await API.get('/api/users/');

            const mappedUsers = response.data.map(user => {
                let joinDate = user.join_date || user.created_at || null;
                if (joinDate) {
                    // Convert ISO string to human-readable format
                    joinDate = new Date(joinDate).toLocaleDateString();
                }

                return {
                    user_id: user.user_id,
                    name: user.name,
                    email: user.email,
                    phone: user.phone,
                    role: user.role || 'driver',
                    status: user.status,
                    profilePicture: user.profilePicture || null,
                    joinDate,
                };
            });

            setUsers(mappedUsers);
            setFilteredUsers(mappedUsers);
        } catch (err) {
            console.error('Failed to fetch users from backend:', err);
            alert('Unable to fetch users from server. Please try again later.');
        }
    };

    useEffect(() => { fetchUsers(); }, []);

    // Filter users whenever filters or list change
    useEffect(() => {
        let result = users;
        if (searchTerm) {
            result = result.filter(user =>
                user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                (user.phone || '').toLowerCase().includes(searchTerm.toLowerCase())
            );
        }
        if (statusFilter !== 'all') result = result.filter(u => u.status === statusFilter);
        if (roleFilter !== 'all') result = result.filter(u => u.role === roleFilter);
        setFilteredUsers(result);
    }, [users, searchTerm, statusFilter, roleFilter]);

    // Add user
    const handleAddUser = async (userData) => {
        try {
            const response = await API.post('/api/users', userData);
            setUsers(prev => [...prev, response.data]);
            setShowAddModal(false);
        } catch (err) {
            console.error(err);
            alert(err.response?.data?.detail || 'Failed to add user');
        }
    };

    // Status change (optimistic update)
    const handleStatusChange = async (userId, newStatus) => {
        try {
            const user = users.find(u => u.user_id === userId);
            if (!user) return;

            await API.put(`/api/users/${user.user_id}`, { status: newStatus });

            setUsers(prevUsers =>
                prevUsers.map(u =>
                    u.user_id === user.user_id ? { ...u, status: newStatus } : u
                )
            );
        } catch (err) {
            console.error(err);
            alert('Failed to update status');
        }
    };

    // Delete user (optimistic update)
    const handleDeleteUser = async (userId) => {
        if (!window.confirm("Are you sure you want to delete this user?")) return;

        try {
            await API.delete(`/api/users/${userId}`);
            setUsers(prev => prev.filter(u => u.user_id !== userId)); // Remove from frontend immediately
        } catch (err) {
            console.error("Delete failed:", err);
            alert(err.response?.data?.detail || 'Failed to delete user');
        }
    };

    // Open edit modal
    const handleEditUser = (user) => {
        setSelectedUser(user);
        setShowEditModal(true);
    };

    // Save edited user
    const handleSaveEditedUser = async (updatedUser) => {
        try {
            await API.put(`/api/users/${updatedUser.user_id}`, {
                name: updatedUser.name,
                email: updatedUser.email,
                phone: updatedUser.phone,
                role: updatedUser.role,
                status: updatedUser.status
            });

            setUsers(prevUsers =>
                prevUsers.map(u =>
                    u.user_id === updatedUser.user_id
                        ? { ...u, ...updatedUser }
                        : u
                )
            );

            setShowEditModal(false);
            setSelectedUser(null);
        } catch (err) {
            console.error(err);
            alert('Failed to update user');
        }
    };

    return (
        <div className="user-management-page">
            <HeaderPages title="Manage Users" onBack={handleBackToDashboard} />

            <div className="user-management-content">
                <div className="user-management-header">
                    <h2>User Management</h2>
                    <button className="btn btn-primary" onClick={() => setShowAddModal(true)}>
                        <AddIcon /> Add New User
                    </button>
                </div>

                <UserFilters
                    searchTerm={searchTerm}
                    setSearchTerm={setSearchTerm}
                    statusFilter={statusFilter}
                    setStatusFilter={setStatusFilter}
                    roleFilter={roleFilter}
                    setRoleFilter={setRoleFilter}
                />

                <UserList
                    users={filteredUsers}
                    onStatusChange={handleStatusChange}
                    onDeleteUser={handleDeleteUser}
                    onEditUser={handleEditUser}
                />

                {showAddModal && (
                    <AddUserModal
                        onClose={() => setShowAddModal(false)}
                        onSave={handleAddUser}
                        existingEmails={users.map(u => u.email)}
                    />
                )}

                {showEditModal && selectedUser && (
                    <EditUserModal
                        user={selectedUser}
                        onClose={() => setShowEditModal(false)}
                        onSave={handleSaveEditedUser}
                    />
                )}
            </div>
        </div>
    );
};

export default UserManagement;
