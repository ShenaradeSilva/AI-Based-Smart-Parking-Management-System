import 'dart:io';
import './api_service.dart';
import './auth_service.dart';

class UserService {
  /// Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await ApiService.get('users/profile', token);

      // Include vehicle info if available
      return {
        'success': true,
        'data': {
          ...response,
          'vehicle_number': response['vehicle_number'] ?? 'N/A',
          'vehicle_type': response['vehicle_type'] ?? 'N/A',
        }
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Update user profile 
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? password,
    String? vehicleNumber,
    String? vehicleType,
    File? profilePicture,
    bool removePicture = false,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      // Prepare fields
      final fields = <String, String>{};
      if (name != null) fields['name'] = name;
      if (email != null) fields['email'] = email;
      if (phone != null) fields['phone'] = phone;
      if (password != null) fields['password'] = password;
      if (vehicleNumber != null) fields['vehicle_number'] = vehicleNumber;
      if (vehicleType != null) fields['vehicle_type'] = vehicleType;
      fields['remove_picture'] = removePicture.toString();

      Map<String, dynamic> response;

      if (profilePicture != null) {
        // Use multipart if there's a profile picture
        response = await ApiService.putMultipart(
          'users/profile/update',
          fields,
          profilePicture,
          token,
          fileFieldName: 'profile_picture',
        );
      } else {
        // Otherwise use normal PUT
        response = await ApiService.put(
          'users/profile/update',
          fields,
          token,
        );
      }

      // Include vehicle info if present
      return {
        'success': true,
        'data': {
          ...response,
          'vehicle_number': response['vehicle_number'] ?? 'N/A',
          'vehicle_type': response['vehicle_type'] ?? 'N/A',
        }
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
