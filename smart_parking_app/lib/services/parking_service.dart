import './api_service.dart';
import './auth_service.dart';

class ParkingService {
  // Fetch slots with optional floor filter (public endpoint)
  static Future<Map<String, dynamic>> fetchSlots({String? floor, String? lotId}) async {
    try {
      final params = <String, String>{};
      if (floor != null && floor.isNotEmpty) params['floor'] = floor;
      if (lotId != null && lotId.isNotEmpty) params['lot_id'] = lotId;
      final query = params.entries
          .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      final endpoint = query.isEmpty ? 'parking/slots' : 'parking/slots?$query';
      final response = await ApiService.getPublic(endpoint);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Get available parking slots
  static Future<Map<String, dynamic>> getAvailableSlots() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await ApiService.get('parking/available', token);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Reserve a parking slot
  static Future<Map<String, dynamic>> reserveSlot(
      String slotId, DateTime startTime, DateTime endTime) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await ApiService.post('parking/reserve', {
        'slot_id': slotId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      });

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Get reservation history
  static Future<Map<String, dynamic>> getReservationHistory() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await ApiService.get('reservations/history', token);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Cancel reservation
  static Future<Map<String, dynamic>> cancelReservation(
      String reservationId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await ApiService.post('reservations/cancel', {
        'reservation_id': reservationId,
      });

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
