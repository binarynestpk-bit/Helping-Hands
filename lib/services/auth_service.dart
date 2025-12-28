import 'api_service.dart';

class AuthService {
  // Simple in-memory user data storage
  static Map<String, dynamic>? _userData;

  // Save user data
  static void setUserData(Map<String, dynamic> user) {
    _userData = user;
  }

  // Get user data
  static Map<String, dynamic>? getUserData() {
    return _userData;
  }

  // Get user's full name
  static String getUserName() {
    if (_userData != null && _userData!['full_name'] != null) {
      return _userData!['full_name'];
    }
    return 'User';
  }

  // Clear user data
  static void clearUserData() {
    _userData = null;
  }

  // Register user
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String password,
    String? email,
    String? phone,
    String? city,
    String? fatherName,
    String? bloodGroup,
  }) async {
    final response = await ApiService.post('/auth/register', {
      'full_name': fullName,
      'password': password,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (city != null && city.isNotEmpty) 'city': city,
      if (fatherName != null && fatherName.isNotEmpty) 'father_name': fatherName,
      if (bloodGroup != null && bloodGroup.isNotEmpty) 'blood_group': bloodGroup,
    });

    // Store token and user data if registration successful
    if (response['success'] == true && response['data']['token'] != null) {
      ApiService.setToken(response['data']['token']);
      if (response['data']['user'] != null) {
        setUserData(response['data']['user']);
      }
    }

    return response;
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await ApiService.post('/auth/login', {
      'identifier': identifier,
      'password': password,
    });

    // Store token and user data if login successful
    if (response['success'] == true && response['data']['token'] != null) {
      ApiService.setToken(response['data']['token']);
      if (response['data']['user'] != null) {
        setUserData(response['data']['user']);
      }
    }

    return response;
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    return await ApiService.get('/auth/profile');
  }

  // Logout user
  static Future<void> logout() async {
    ApiService.removeToken();
    clearUserData();
    try {
      await ApiService.post('/auth/logout', {}, includeAuth: true);
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    final token = ApiService.getToken();
    return token != null;
  }
}