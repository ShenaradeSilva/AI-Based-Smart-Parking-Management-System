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

      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? password,
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
      if (name != null && name.isNotEmpty) fields['name'] = name;
      if (email != null && email.isNotEmpty) fields['email'] = email;
      if (phone != null && phone.isNotEmpty) fields['phone'] = phone;
      if (password != null && password.isNotEmpty)
        fields['password'] = password;
      fields['remove_picture'] = removePicture.toString();

      Map<String, dynamic> response;

      if (profilePicture != null) {
        response = await ApiService.putMultipart(
          'users/profile/update',
          fields,
          profilePicture,
          token,
          fileFieldName: 'profile_picture',
        );
      } else {
        // Use form data for regular updates
        response = await ApiService.put(
          'users/profile/update',
          fields,
          token,
        );
      }

      return response;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Add vehicle to profile
  static Future<Map<String, dynamic>> addVehicle({
    required String plateNumber,
    required String type,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await ApiService.postMultipart(
        'users/profile/vehicles-add',
        {
          'plate_number': plateNumber,
          'vehicle_type': type,
        },
        null,
        token,
      );

      return response;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Remove vehicle from profile
  static Future<Map<String, dynamic>> removeVehicle(String vehicleId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await ApiService.delete(
        'users/profile/vehicles-remove/$vehicleId',
        token,
      );

      return response;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Update profile picture only
  static Future<Map<String, dynamic>> updateProfilePicture(
      File profilePicture) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await ApiService.putMultipart(
        'users/profile/update-picture',
        {},
        profilePicture,
        token,
        fileFieldName: 'profile_picture',
      );

      return response;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Remove profile picture
  static Future<Map<String, dynamic>> removeProfilePicture() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await ApiService.delete(
        'users/profile/delete-picture',
        token,
      );

      return response;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
