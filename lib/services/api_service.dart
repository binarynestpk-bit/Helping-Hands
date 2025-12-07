import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Choose the correct baseUrl for your setup:

  // For Android Emulator (most common)
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // For iOS Simulator (uncomment if using iOS)
  // static const String baseUrl = 'http://localhost:3000/api';

  // For Physical Device (replace with your computer's IP address)
  // static const String baseUrl = 'http://YOUR_COMPUTER_IP:3000/api';
  // Example: static const String baseUrl = 'http://192.168.1.100:3000/api';

  // Simple in-memory token storage (for testing)
  static String? _token;

  // Get stored token
  static String? getToken() => _token;

  // Store token
  static void setToken(String token) => _token = token;

  // Remove token
  static void removeToken() => _token = null;

  // Get headers with auth token
  static Map<String, String> getHeaders({bool includeAuth = true}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // POST request with better error handling
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {bool includeAuth = false}) async {
    try {
      print('🌐 Making POST request to: $baseUrl$endpoint');
      print('📦 Request data: $data');

      final headers = getHeaders(includeAuth: includeAuth);
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      ).timeout(Duration(seconds: 30)); // Add timeout

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Network error: $e');
      if (e.toString().contains('SocketException')) {
        throw Exception('Cannot connect to server. Please check if backend is running.');
      }
      throw Exception('Network error: $e');
    }
  }

  // GET request with better error handling
  static Future<Map<String, dynamic>> get(String endpoint, {bool includeAuth = true}) async {
    try {
      print('🌐 Making GET request to: $baseUrl$endpoint');

      final headers = getHeaders(includeAuth: includeAuth);
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(Duration(seconds: 30)); // Add timeout

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ Network error: $e');
      if (e.toString().contains('SocketException')) {
        throw Exception('Cannot connect to server. Please check if backend is running.');
      }
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = getHeaders(includeAuth: true);
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      ).timeout(Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = getHeaders(includeAuth: true);
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle API response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw ApiException(
          message: data['message'] ?? 'Unknown error occurred',
          statusCode: response.statusCode,
          errors: data['errors'],
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Failed to parse server response',
        statusCode: response.statusCode,
        errors: null,
      );
    }
  }

  // Test connection method
  static Future<bool> testConnection() async {
    try {
      final response = await get('/test', includeAuth: false);
      return response['success'] == true;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  // =============================================
  // FAMILY SUPPORT SPECIFIC METHODS
  // =============================================

  // Create family request
  static Future<Map<String, dynamic>> createFamilyRequest(Map<String, dynamic> requestData) async {
    return await post('/family/requests', requestData, includeAuth: true);
  }

  // Get all family requests (public)
  static Future<Map<String, dynamic>> getAllFamilyRequests() async {
    return await get('/family/requests', includeAuth: false);
  }

  // Get specific family request
  static Future<Map<String, dynamic>> getFamilyRequest(String requestId) async {
    return await get('/family/requests/$requestId', includeAuth: false);
  }

  // Get user's family requests with enhanced data
  static Future<Map<String, dynamic>> getUserFamilyRequests({String? status}) async {
    String endpoint = '/family/user/requests-enhanced';
    if (status != null && status != 'all') {
      endpoint += '?status=$status';
    }
    return await get(endpoint, includeAuth: true);
  }

  // Donate to family request
  static Future<Map<String, dynamic>> donateToFamily(String requestId, Map<String, dynamic> donationData) async {
    return await post('/family/donate/$requestId', donationData, includeAuth: true);
  }

  // Cancel family request
  static Future<Map<String, dynamic>> cancelFamilyRequest(String requestId, String reason) async {
    return await put('/family/requests/$requestId/cancel', {
      'reason': reason,
    });
  }

  // Update family request (for editing)
  static Future<Map<String, dynamic>> updateFamilyRequest(String requestId, Map<String, dynamic> requestData) async {
    return await put('/family/requests/$requestId', requestData);
  }

  // Get user's family donations
  static Future<Map<String, dynamic>> getUserFamilyDonations() async {
    return await get('/family/user/donations', includeAuth: true);
  }

  // =============================================
  // EDUCATION SUPPORT METHODS (existing)
  // =============================================

  // Create education request
  static Future<Map<String, dynamic>> createEducationRequest(Map<String, dynamic> requestData) async {
    return await post('/education/requests', requestData, includeAuth: true);
  }

  // Get all education requests (public)
  static Future<Map<String, dynamic>> getAllEducationRequests() async {
    return await get('/education/requests', includeAuth: false);
  }

  // Get specific education request
  static Future<Map<String, dynamic>> getEducationRequest(String requestId) async {
    return await get('/education/requests/$requestId', includeAuth: false);
  }

  // Get user's education requests
  static Future<Map<String, dynamic>> getUserEducationRequests() async {
    return await get('/education/user/requests', includeAuth: true);
  }

  // Donate to education request
  static Future<Map<String, dynamic>> donateToEducation(String requestId, Map<String, dynamic> donationData) async {
    return await post('/education/donate/$requestId', donationData, includeAuth: true);
  }

  // Get user's education donations
  static Future<Map<String, dynamic>> getUserEducationDonations() async {
    return await get('/education/user/donations', includeAuth: true);
  }

  // =============================================
  // BLOOD DONATION METHODS (existing)
  // =============================================

  // Create blood request
  static Future<Map<String, dynamic>> createBloodRequest(Map<String, dynamic> requestData) async {
    return await post('/blood/requests', requestData, includeAuth: true);
  }

  // Get all blood requests (public)
  static Future<Map<String, dynamic>> getAllBloodRequests() async {
    return await get('/blood/requests', includeAuth: false);
  }

  // Get specific blood request
  static Future<Map<String, dynamic>> getBloodRequest(String requestId) async {
    return await get('/blood/requests/$requestId', includeAuth: false);
  }

  // Get user's blood requests with enhanced data
  static Future<Map<String, dynamic>> getUserBloodRequests({String? status}) async {
    String endpoint = '/blood/user/requests-enhanced';
    if (status != null && status != 'all') {
      endpoint += '?status=$status';
    }
    return await get(endpoint, includeAuth: true);
  }

  // Donate blood to request
  static Future<Map<String, dynamic>> donateBlood(String requestId, Map<String, dynamic> donationData) async {
    return await post('/blood/donate/$requestId', donationData, includeAuth: true);
  }

  // Cancel blood request
  static Future<Map<String, dynamic>> cancelBloodRequest(String requestId, String reason) async {
    return await put('/blood/requests/$requestId/cancel', {
      'reason': reason,
    });
  }

  // Mark blood request as fulfilled
  static Future<Map<String, dynamic>> fulfillBloodRequest(String requestId, String method, String notes) async {
    return await put('/blood/requests/$requestId/fulfill', {
      'fulfilled_through': method,
      'notes': notes,
    });
  }

  // Get user's blood donations
  static Future<Map<String, dynamic>> getUserBloodDonations() async {
    return await get('/blood/user/donations', includeAuth: true);
  }
}

// Custom exception class
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final List<dynamic>? errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.map((e) => e['msg'] ?? e.toString()).join(', ');
    }
    return message;
  }
}