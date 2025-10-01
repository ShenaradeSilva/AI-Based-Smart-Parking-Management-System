import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import './api_service.dart';

class AuthService {
  // Login method
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await ApiService.post('auth/login', {
        'email': email,
        'password': password,
      });

      // Save token to shared preferences
      if (response['success'] == true && response['data']['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['data']['token']);
        await prefs.setString(
            'user_data', json.encode(response['data']['user']));
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Register method
  static Future<Map<String, dynamic>> register(String name, String email,
      String mobile, String vehicleNumber, String password) async {
    try {
      final response = await ApiService.post('auth/register', {
        'name': name,
        'email': email,
        'mobile': mobile,
        'vehicle_number': vehicleNumber,
        'password': password,
      });

      // Save token to shared preferences if backend returns it
      if (response['success'] == true &&
          response['data'] != null &&
          response['data']['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['data']['token']);
        await prefs.setString(
            'user_data', json.encode(response['data']['user']));
      }

      return response;
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
}
