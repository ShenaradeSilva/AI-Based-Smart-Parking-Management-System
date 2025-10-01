import 'package:intl/intl.dart';

class Reservation {
  final String id;
  final String slotNumber;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double price;
  final String status;
  final String zone;

  Reservation({
    required this.id,
    required this.slotNumber,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
    required this.zone,
  });

  String get formattedDate => DateFormat.yMMMd().format(date);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slotNumber': slotNumber,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'price': price,
      'status': status,
      'zone': zone,
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      slotNumber: json['slotNumber'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      price: json['price'],
      status: json['status'],
      zone: json['zone'],
    );
  }
}