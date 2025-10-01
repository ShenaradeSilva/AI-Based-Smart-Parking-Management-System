class ParkingCounter {
  final int total;
  final int occupied;
  final int available;

  ParkingCounter({
    required this.total,
    required this.occupied,
    required this.available,
  });

  factory ParkingCounter.fromJson(Map<String, dynamic> json) {
    return ParkingCounter(
      total: json['total'] ?? 0,
      occupied: json['occupied'] ?? 0,
      available: json['available'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'occupied': occupied,
      'available': available,
    };
  }

  // Create a copy with updated values
  ParkingCounter copyWith({
    int? total,
    int? occupied,
    int? available,
  }) {
    return ParkingCounter(
      total: total ?? this.total,
      occupied: occupied ?? this.occupied,
      available: available ?? this.available,
    );
  }

  // Calculate percentage of occupied slots
  double get occupancyRate {
    if (total == 0) return 0.0;
    return occupied / total;
  }

  // Calculate percentage of available slots
  double get availabilityRate {
    if (total == 0) return 0.0;
    return available / total;
  }
}