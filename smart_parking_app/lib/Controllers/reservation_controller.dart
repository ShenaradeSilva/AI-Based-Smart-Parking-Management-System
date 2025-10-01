import '../models/reservation.dart';

class ReservationController {
  final List<Reservation> reservations = [
    Reservation(
      id: '1',
      slotNumber: 'A1',
      date: DateTime(2023, 8, 25),
      startTime: '10:00',
      endTime: '14:00',
      price: 20.0,
      status: 'Active',
      zone: 'A',
    ),
    Reservation(
      id: '2',
      slotNumber: 'B3',
      date: DateTime(2023, 8, 26),
      startTime: '13:00',
      endTime: '17:00',
      price: 20.0,
      status: 'Active',
      zone: 'B',
    ),
    Reservation(
      id: '3',
      slotNumber: 'A4',
      date: DateTime(2023, 8, 20),
      startTime: '09:00',
      endTime: '12:00',
      price: 15.0,
      status: 'Completed',
      zone: 'A',
    ),
    Reservation(
      id: '4',
      slotNumber: 'B2',
      date: DateTime(2023, 8, 18),
      startTime: '14:00',
      endTime: '18:00',
      price: 20.0,
      status: 'Completed',
      zone: 'B',
    ),
  ];

  Future<List<Reservation>> getActiveReservations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return reservations.where((r) => r.status == 'Active').toList();
  }

  Future<List<Reservation>> getReservationHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return reservations.where((r) => r.status == 'Completed').toList();
  }

  Future<Reservation> getReservationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return reservations.firstWhere((r) => r.id == id);
  }
}