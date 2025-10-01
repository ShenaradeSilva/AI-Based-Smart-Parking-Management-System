import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import './api_service.dart';
import './auth_service.dart';

class UserService {
  // Upload profile photo
  static Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      // Read image file and convert to base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final imageData = 'data:image/jpeg;base64,$base64Image';

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/users/profile/photo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'photo': imageData}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to upload photo'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to fetch profile'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> userData) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(userData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update profile'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
