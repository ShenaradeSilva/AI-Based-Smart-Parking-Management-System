import vehiclesData from './vehiclesData';

export const bookings = () => {
  const locationsList = ['Colombo City Center', 'One Galle Face Mall Colombo'];
  const statuses = ['Confirmed', 'Upcoming', 'Completed', 'Cancelled'];
  const bookings = [];

  for (let i = 1; i <= 12; i++) {
    const day = Math.floor(Math.random() * 28) + 1;
    const month = Math.floor(Math.random() * 3) + 10;
    const date = `2025-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;

    const startHour = Math.floor(Math.random() * 12) + 8;
    const duration = Math.floor(Math.random() * 6) + 2;
    const endHour = startHour + duration;
    const time = `${startHour}:00 ${startHour >= 12 ? 'PM' : 'AM'} - ${endHour}:00 ${endHour >= 12 ? 'PM' : 'AM'}`;

    const amount = Math.floor(Math.random() * 3000) + 100;

    bookings.push({
      id: i,
      date,
      time,
      location: locationsList[Math.floor(Math.random() * locationsList.length)],
      slot: `${String.fromCharCode(65 + Math.floor(Math.random() * 5))}-${Math.floor(Math.random() * 20) + 1}`,
      status: statuses[Math.floor(Math.random() * statuses.length)],
      amount: `LKR ${amount.toLocaleString()}`,
      vehicle: vehiclesData[Math.floor(Math.random() * vehiclesData.length)]?.plateNumber || '',
      paymentMethod: ['Credit Card', 'Debit Card', 'UPI', 'Wallet'][Math.floor(Math.random() * 4)],
      paymentStatus: ['Paid', 'Pending', 'Refunded'][Math.floor(Math.random() * 3)],
      bookingReference: `REF${Math.floor(Math.random() * 10000) + 1000}`,
      duration: `${duration} hours`
    });
  }

  return bookings;
};
