const notificationsData = [
  {
    id: 1,
    type: 'detection',
    title: 'Frequent Use Detected',
    content: 'Vehicle: ABC-123 has used Slot #87 eight times this week.',
    location: 'Downtown Lot A - Unusual pattern',
    time: 'Just Now',
    read: false
  },
  {
    id: 2,
    type: 'pending',
    title: 'Cancellation Request Pending',
    content: 'User: j.smith@email.com wants to cancel Booking #7284',
    slot: 'Slot: #C3 - Time: 14:00 – 16:00',
    time: '15 mins ago',
    read: false,
    action: 'Approve'
  },
  {
    id: 3,
    type: 'security',
    title: 'Security Alert',
    content: '5 failed login attempts from IP 192.168.10.44',
    detail: 'Possible brute-force attack detected',
    time: '2 hours ago',
    read: false,
    action: 'View Logs'
  },
  {
    id: 4,
    type: 'success',
    title: 'Login Success!',
    content: 'Welcome! You have successfully logged into the system.',
    time: 'Today at 9:15AM',
    read: true
  },
  {
    id: 5,
    type: 'success',
    title: 'Account Creation Success!',
    content: 'You have successfully created a new Account.',
    time: 'Today at 9:00 AM',
    read: true,
    action: 'To Dashboard'
  }
];

export default notificationsData;
