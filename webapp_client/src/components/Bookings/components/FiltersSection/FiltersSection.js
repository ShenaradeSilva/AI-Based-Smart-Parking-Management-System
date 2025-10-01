import React from 'react';
import './FiltersSection.css';
import { AddIcon } from '../../../Icons/Icons';

const FiltersSection = ({ filters, locations, onFilterChange, onClearFilters, onCreateBooking }) => {
  return (
    <div className="filters-section">
      <div className="filters-header">
        <h3>Filter Bookings</h3>
        <button className="create-booking-btn" onClick={onCreateBooking}>
          <AddIcon /> Create Booking
        </button>
      </div>

      <div className="filters-grid">
        <div className="filter-group">
          <label>Date</label>
          <input type="date" name="date" value={filters.date} onChange={onFilterChange} min="2025-10-01"/>
        </div>
        <div className="filter-group">
          <label>Time</label>
          <select name="time" value={filters.time} onChange={onFilterChange}>
            <option value="">All Times</option>
            <option value="AM">Morning (AM)</option>
            <option value="PM">Afternoon (PM)</option>
          </select>
        </div>
        <div className="filter-group">
          <label>Location</label>
          <select name="location" value={filters.location} onChange={onFilterChange}>
            <option value="">All Locations</option>
            {locations.map(loc => <option key={loc} value={loc}>{loc}</option>)}
          </select>
        </div>
        <div className="filter-group">
          <label>Status</label>
          <select name="status" value={filters.status} onChange={onFilterChange}>
            <option value="all">All Statuses</option>
            <option value="Confirmed">Confirmed</option>
            <option value="Upcoming">Upcoming</option>
            <option value="Completed">Completed</option>
            <option value="Cancelled">Cancelled</option>
          </select>
        </div>
        <div className="filter-actions">
          <button className="clear-filters-btn" onClick={onClearFilters}>Clear Filters</button>
        </div>
      </div>
    </div>
  );
};

export default FiltersSection;
