import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Backend base URL selection based on platform
  static String get baseUrl {
    if (kIsWeb) {
      // Flutter Web runs in the browser; access backend via localhost
      return 'http://localhost:5000/api';
    }
    // Android emulator loopback; adjust for iOS simulator or physical device as needed
    return 'http://10.0.2.2:5000/api';
  }

  // Generic POST method
  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      if (kDebugMode) {
        print('API Call: POST $baseUrl/$endpoint');
        print('Request Data: $data');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      final responseData = json.decode(response.body);

      // Treat 200 OK and 201 Created as success for POST
      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        // Propagate backend error message when available
        throw Exception(responseData is Map && responseData['message'] != null
            ? responseData['message']
            : 'Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      throw Exception('Network error: $e');
    }
  }

  // Generic GET method WITHOUT authentication
  static Future<Map<String, dynamic>> getPublic(String endpoint) async {
    try {
      if (kDebugMode) {
        print('API Call: GET $baseUrl/$endpoint');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ??
            'Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      throw Exception('Network error: $e');
    }
  }

  // Generic GET method with authentication
  static Future<Map<String, dynamic>> get(String endpoint, String token) async {
    try {
      if (kDebugMode) {
        print('API Call: GET $baseUrl/$endpoint');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ??
            'Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      throw Exception('Network error: $e');
    }
  }

  // Generic PUT method with authentication
  static Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data, String token) async {
    try {
      if (kDebugMode) {
        print('API Call: PUT $baseUrl/$endpoint');
        print('Request Data: $data');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ??
            'Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      throw Exception('Network error: $e');
    }
  }
}
