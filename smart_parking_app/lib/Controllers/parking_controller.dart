import '../models/parking_slot.dart';
import '../models/reservation.dart';

class ParkingController {
  final List<ParkingSlot> parkingSlots = [
    ParkingSlot(number: 'A1', isAvailable: true, isDisabled: false, zone: 'A'),
    ParkingSlot(number: 'A2', isAvailable: false, isDisabled: false, zone: 'A'),
    ParkingSlot(number: 'A3', isAvailable: true, isDisabled: true, zone: 'A'),
    ParkingSlot(number: 'A4', isAvailable: true, isDisabled: false, zone: 'A'),
    ParkingSlot(number: 'B1', isAvailable: false, isDisabled: false, zone: 'B'),
    ParkingSlot(number: 'B2', isAvailable: true, isDisabled: false, zone: 'B'),
    ParkingSlot(number: 'B3', isAvailable: true, isDisabled: false, zone: 'B'),
    ParkingSlot(number: 'B4', isAvailable: false, isDisabled: false, zone: 'B'),
    ParkingSlot(number: 'C1', isAvailable: true, isDisabled: false, zone: 'C'),
    ParkingSlot(number: 'C2', isAvailable: true, isDisabled: true, zone: 'C'),
    ParkingSlot(number: 'C3', isAvailable: false, isDisabled: false, zone: 'C'),
    ParkingSlot(number: 'C4', isAvailable: true, isDisabled: false, zone: 'C'),
  ];

  Future<List<ParkingSlot>> getAvailableSlots() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return parkingSlots.where((slot) => slot.isAvailable).toList();
  }

  Future<List<ParkingSlot>> getAllSlots() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return parkingSlots;
  }

  Future<Reservation> createReservation({
    required String slotNumber,
    required DateTime date,
    required String startTime,
    required String endTime,
    required String zone,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final start = DateTime(date.year, date.month, date.day, 
        int.parse(startTime.split(':')[0]), int.parse(startTime.split(':')[1]));
    final end = DateTime(date.year, date.month, date.day, 
        int.parse(endTime.split(':')[0]), int.parse(endTime.split(':')[1]));
    final duration = end.difference(start);
    final hours = duration.inHours + (duration.inMinutes % 60 > 0 ? 1 : 0);
    final price = hours * 5.0;
    
    return Reservation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      slotNumber: slotNumber,
      date: date,
      startTime: startTime,
      endTime: endTime,
      price: price,
      status: 'Confirmed',
      zone: zone,
    );
  }

  Future<bool> cancelReservation(String reservationId) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<Map<String, int>> getParkingStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final total = parkingSlots.length;
    final occupied = parkingSlots.where((slot) => !slot.isAvailable).length;
    final available = total - occupied;
    
    return {
      'total': total,
      'occupied': occupied,
      'available': available,
    };
  }
}