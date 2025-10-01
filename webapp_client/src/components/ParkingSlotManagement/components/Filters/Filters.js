import React, { useEffect, useState } from 'react';
import API from '../../../../api/axios';
import './Filters.css';

const Filters = ({
  locations,
  selectedLocation,
  dateFilter,
  timeFilter,
  onLocationChange,
  onDateFilterChange,
  onTimeFilterChange,
  onClearFilters
}) => {
  const [allLocations, setAllLocations] = useState(locations || []);

  // Fetch locations from backend and merge with mock data
  useEffect(() => {
    const fetchLocations = async () => {
      try {
        const res = await API.get('/parking/locations');
        const backendLocations = res.data;

        // Merge backend locations with mock data without duplicates
        const mergedLocations = [
          ...locations,
          ...backendLocations.filter(
            bLoc => !locations.some(mLoc => 
              (mLoc.id || mLoc.location_id) === bLoc.location_id
            )
          )
        ];

        setAllLocations(mergedLocations);
      } catch (err) {
        console.error('Error fetching locations from backend', err);
        // fallback to mock data
        setAllLocations(locations);
      }
    };

    fetchLocations();
  }, [locations]);

  // Generate time options every 30 minutes
  const generateTimeOptions = () => {
    const options = [];
    for (let hour = 0; hour < 24; hour++) {
      for (let minute = 0; minute < 60; minute += 30) {
        const timeStr = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
        options.push(<option key={timeStr} value={timeStr}>{timeStr}</option>);
      }
    }
    return options;
  };

  return (
    <div className="filters-container">
      {/* Location Filter */}
      <div className="filter-group">
        <label htmlFor="location-filter">Filter by Location:</label>
        <select 
          id="location-filter"
          value={selectedLocation} 
          onChange={(e) => onLocationChange(e.target.value)}
        >
          <option value="All Locations">All Locations</option>
          {allLocations.map(location => (
            <option
              key={location.location_id || location.id} // support backend and mock data
              value={location.name}
            >
              {location.name}
            </option>
          ))}
        </select>
      </div>
      
      {/* Date Filter */}
      <div className="filter-group">
        <label htmlFor="date-filter">Filter by Date:</label>
        <input
          id="date-filter"
          type="date"
          value={dateFilter}
          onChange={(e) => onDateFilterChange(e.target.value)}
        />
      </div>
      
      {/* Time Filter */}
      <div className="filter-group">
        <label htmlFor="time-filter">Filter by Time:</label>
        <select
          id="time-filter"
          value={timeFilter}
          onChange={(e) => onTimeFilterChange(e.target.value)}
        >
          <option value="">All Times</option>
          {generateTimeOptions()}
        </select>
      </div>
      
      {/* Clear Filters */}
      <div className="filter-group">
        <button 
          className="clear-filters-button"
          onClick={onClearFilters}
        >
          Clear Filters
        </button>
      </div>
    </div>
  );
};

export default Filters;
