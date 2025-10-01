const analyticsData = {
  historical: {
    weekdays_peak: "8:00-10:00 AM, 5:00-7:00 PM",
    weekend_peak: "12:00-6:00 PM"
  },

  highest_demand: "Friday 5:30 PM (95% occupancy)",

  ai_predictions: {
    tomorrow_peak: "2:00-4:00 PM",
    expected: "85% occupancy (Confidence: 84.2%)"
  },

  weekly_trend: "Increasing demand on Wednesdays",
  recommendation: "Dynamic pricing implementation",
  capacity_alert: "Saturday expected to reach 100%",
  suggestion: "Open additional temporary slots",

  revenue: {
    total_reservations: 120,
    completed_reservations: 95,
    cancelled_reservations: 25
  },

  trends: [
    { date: '2025-09-17', reservations_count: 15 },
    { date: '2025-09-18', reservations_count: 20 },
    { date: '2025-09-19', reservations_count: 18 },
    { date: '2025-09-20', reservations_count: 22 },
    { date: '2025-09-21', reservations_count: 17 },
    { date: '2025-09-22', reservations_count: 21 },
    { date: '2025-09-23', reservations_count: 25 },
  ],

  occupancy: {
    total_slots: 200,
    occupied_slots: 120,
    available_slots: 80,
    occupancy_rate: 60
  },

  predictions: [
    { date: '2025-09-24', predicted_reservations: 26 },
    { date: '2025-09-25', predicted_reservations: 28 },
    { date: '2025-09-26', predicted_reservations: 24 },
    { date: '2025-09-27', predicted_reservations: 30 },
    { date: '2025-09-28', predicted_reservations: 29 },
    { date: '2025-09-29', predicted_reservations: 31 },
    { date: '2025-09-30', predicted_reservations: 27 },
  ],

  vehicleVisitFrequency: {
    total_vehicles: 50,
    most_frequent_vehicle: { vehicle_id: "ABC-1234", visits: 25 },
    daily_visits: [
      { date: '2025-09-17', visits: 8 },
      { date: '2025-09-18', visits: 10 },
      { date: '2025-09-19', visits: 12 },
      { date: '2025-09-20', visits: 14 },
      { date: '2025-09-21', visits: 9 },
      { date: '2025-09-22', visits: 15 },
      { date: '2025-09-23', visits: 18 }
    ],
    vehicles: [
      { vehicle: 'ABC-1234', totalVisits: 25, preferredSlot: 'A-15 (80%)', avgDuration: '2.5 hours' },
      { vehicle: 'XYZ-5678', totalVisits: 18, preferredSlot: 'A-08 (72%)', avgDuration: '3.2 hours' },
      { vehicle: 'DEF-9012', totalVisits: 15, preferredSlot: 'A-12 (67%)', avgDuration: '1.8 hours' }
    ],
    insights: [
      {
        title: 'Loyalty Program Opportunity',
        description: '15 vehicles have 20+ visits - consider implementing loyalty rewards'
      },
      {
        title: 'Slot Preference Pattern',
        description: 'Vehicle ABC-1234 prefers Slot A-15 - consider reserved slot option'
      },
      {
        title: 'Revenue Optimization',
        description: 'High-frequency users could benefit from monthly passes (potential 23% revenue increase)'
      }
    ]
  }
};

export default analyticsData;
