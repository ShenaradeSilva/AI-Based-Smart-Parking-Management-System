class ParkingSlot {
  final String number;
  final bool isAvailable;
  final bool isDisabled;
  final String zone;

  ParkingSlot({
    required this.number,
    required this.isAvailable,
    required this.isDisabled,
    required this.zone,
  });

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'isAvailable': isAvailable,
      'isDisabled': isDisabled,
      'zone': zone,
    };
  }

  factory ParkingSlot.fromJson(Map<String, dynamic> json) {
    return ParkingSlot(
      number: json['number'],
      isAvailable: json['isAvailable'],
      isDisabled: json['isDisabled'],
      zone: json['zone'],
    );
  }
}