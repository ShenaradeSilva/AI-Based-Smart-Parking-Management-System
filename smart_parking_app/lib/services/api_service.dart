import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

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

  static Future<Map<String, dynamic>> postPublic(
      String endpoint, Map<String, dynamic> data) async {
    try {
      if (kDebugMode) print('POST Public: $baseUrl/$endpoint => $data');

      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final responseData = json.decode(response.body);

      if (kDebugMode) {
        print(
            'POST Public Response: ${response.statusCode} => ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ??
            'Failed POST request: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('POST Public Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Generic POST request
  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      if (kDebugMode) print('POST: $baseUrl/$endpoint => $data');

      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      final responseData = json.decode(response.body);

      if (kDebugMode) {
        print('POST Response: ${response.statusCode} => ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ??
            'Failed POST request: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('POST Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // POST Multipart (for file upload) - Web compatible
  static Future<Map<String, dynamic>> postMultipart(
      String endpoint, Map<String, String> fields, File? file, String token,
      {String fileFieldName = 'file', String? mimeType}) async {
    try {
      if (kDebugMode) print('POST Multipart: $baseUrl/$endpoint');

      final uri = Uri.parse('$baseUrl/$endpoint');

      if (kIsWeb) {
        // Web implementation - convert to regular POST
        final data = {...fields};
        if (file != null) {
          final bytes = await file.readAsBytes();
          data['file_base64'] = base64Encode(bytes);
          data['mime_type'] = mimeType ?? 'image/jpeg';
        }

        return await post(endpoint, data);
      } else {
        // Mobile implementation
        final request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields.addAll(fields);

        if (file != null) {
          final mimeParts = (mimeType ?? 'image/jpeg').split('/');
          request.files.add(await http.MultipartFile.fromPath(
            fileFieldName,
            file.path,
            contentType: MediaType(mimeParts[0], mimeParts[1]),
          ));
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        final responseData = json.decode(response.body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ??
              'Failed Multipart POST request: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('POST Multipart Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Generic GET request (no token)
  static Future<Map<String, dynamic>> getPublic(String endpoint) async {
    try {
      if (kDebugMode) print('GET Public: $baseUrl/$endpoint');

      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      final responseData = json.decode(response.body);

      if (kDebugMode) {
        print(
            'GET Public Response: ${response.statusCode} => ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ??
            'Failed GET request: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('GET Public Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Generic GET request (with token)
  static Future<Map<String, dynamic>> get(String endpoint, String token) async {
    try {
      if (kDebugMode) print('GET: $baseUrl/$endpoint');

      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (kDebugMode) {
        print('GET Response: ${response.statusCode} => ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ??
            'Failed GET request: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('GET Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Generic PUT request (with token)
  static Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data, String token) async {
    try {
      if (kDebugMode) print('PUT: $baseUrl/$endpoint => $data');

      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      final responseData = json.decode(response.body);

      if (kDebugMode) {
        print('PUT Response: ${response.statusCode} => ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ??
            'Failed PUT request: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('PUT Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // PUT Multipart (for file upload) - Web compatible
  static Future<Map<String, dynamic>> putMultipart(
      String endpoint, Map<String, String> fields, File? file, String token,
      {String fileFieldName = 'profile_picture', String? mimeType}) async {
    try {
      if (kDebugMode) print('PUT Multipart: $baseUrl/$endpoint');

      final uri = Uri.parse('$baseUrl/$endpoint');

      if (kIsWeb) {
        // Web implementation - convert file to base64 and send as regular PUT
        if (file != null) {
          final bytes = await file.readAsBytes();
          final base64Image = base64Encode(bytes);
          final webData = {
            ...fields,
            'profile_picture_base64': base64Image,
            'mime_type': mimeType ?? 'image/jpeg',
          };

          return await put(endpoint, webData, token);
        } else {
          return await put(endpoint, fields, token);
        }
      } else {
        // Mobile implementation - use multipart
        final request = http.MultipartRequest('PUT', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields.addAll(fields);

        if (file != null) {
          final mimeParts = (mimeType ?? 'image/jpeg').split('/');
          request.files.add(await http.MultipartFile.fromPath(
            fileFieldName,
            file.path,
            contentType: MediaType(mimeParts[0], mimeParts[1]),
          ));
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);
        final responseData = json.decode(response.body);

        if (kDebugMode) {
          print(
              'PUT Multipart Response: ${response.statusCode} => ${response.body}');
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ??
              'Failed Multipart PUT request: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('PUT Multipart Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // DELETE request (with token)
  static Future<Map<String, dynamic>> delete(
      String endpoint, String token) async {
    try {
      if (kDebugMode) print('DELETE: $baseUrl/$endpoint');

      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (kDebugMode) {
        print('DELETE Response: ${response.statusCode} => ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ??
            'Failed DELETE request: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('DELETE Error: $e');
      throw Exception('Network error: $e');
    }
  }
}
