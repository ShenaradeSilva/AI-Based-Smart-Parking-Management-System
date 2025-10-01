import React from 'react';
import BookingCard from '../BookingCard/BookingCard';
import NoBookings from '../NoBookings/NoBookings';
import './BookingsList.css';

const BookingsList = ({ bookings, onViewDetails, onCancel }) => {
  if (bookings.length === 0) {
    return <NoBookings />;
  }

  return (
    <div className="bookings-list">
      {bookings.map(booking => (
        <BookingCard
          key={booking.id}
          booking={booking}
          onViewDetails={onViewDetails} // fixed here
          onCancel={onCancel}           // fixed here
        />
      ))}
    </div>
  );
};

export default BookingsList;
