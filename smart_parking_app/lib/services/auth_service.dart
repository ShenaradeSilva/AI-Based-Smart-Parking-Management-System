import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './api_service.dart';

class AuthService {
  // Login method
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await ApiService.post('auth/signin', {
        'email': email,
        'password': password,
        'platform': 'mobile', // driver mobile login
      });

      // Save token to shared preferences
      if (response['access_token'] != null && response['user'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['access_token']);
        await prefs.setString('user_data', json.encode(response['user']));
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Register method for driver signup
  static Future<Map<String, dynamic>> register(
      String name,
      String email,
      String phone,
      String vehicleNumber,
      String vehicleType,
      String password) async {
    try {
      final response = await ApiService.post('auth/driver/signup', {
        'name': name,
        'email': email,
        'phone': phone,
        'vehicle_number': vehicleNumber,
        'vehicle_type': vehicleType,
        'password': password,
      });

      // If backend returns user object
      if (response['user'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(response['user']));
      }

      return {
        'success': true,
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  // Get auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }

  // Logout method
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  // Request password reset (send code)
  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await ApiService.post('auth/reset-password/request', {
        'email': email,
      });
      return {
        'success': true,
        'message': response['message'] ?? 'Reset code sent',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Verify code
  static Future<Map<String, dynamic>> verifyResetCode(
      String email, String code) async {
    try {
      final response = await ApiService.post('auth/reset-password/verify', {
        'email': email,
        'code': code,
      });
      return {
        'success': true,
        'message': response['message'] ?? 'Code verified',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Confirm reset with new password
  static Future<Map<String, dynamic>> confirmPasswordReset(
      String email, String code, String newPassword) async {
    try {
      final response = await ApiService.post('auth/reset-password/confirm', {
        'email': email,
        'code': code,
        'new_password': newPassword,
      });
      return {
        'success': true,
        'message': response['message'] ?? 'Password reset successful',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Reset Password with verification code
  static Future<Map<String, dynamic>> resetPassword(
      String email, String code, String newPassword) async {
    try {
      final response = await ApiService.post('auth/reset-password/confirm', {
        'email': email,
        'code': code, // required by backend
        'new_password': newPassword,
      });

      return {
        'success': true,
        'message': response['message'] ?? 'Password reset successful',
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
