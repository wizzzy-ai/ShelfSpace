import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';

class AuthService {
  factory AuthService() => _instance;

  AuthService._internal();

  static final AuthService _instance = AuthService._internal();
  static const String _tokenKey = 'shelfspace_auth_token';
  static const String _userKey = 'shelfspace_auth_user';

  final String _baseUrl = ApiConstants.baseUrl;

  String? _token;
  Map<String, dynamic>? _currentUser;

  String? get token => _token;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null;

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);

    if (savedToken == null || savedToken.isEmpty) {
      _token = null;
      _currentUser = null;
      return;
    }

    _token = savedToken;

    final savedUser = prefs.getString(_userKey);
    if (savedUser != null && savedUser.isNotEmpty) {
      try {
        final decoded = jsonDecode(savedUser);
        if (decoded is Map<String, dynamic>) {
          _currentUser = decoded;
        } else if (decoded is Map) {
          _currentUser = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        _currentUser = null;
      }
    }
  }

  Future<void> persistSession({
    required String token,
    required Map<String, dynamic> user,
    bool rememberMe = true,
  }) async {
    _token = token;
    _currentUser = user;

    if (!rememberMe) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  Future<void> clearSession() async {
    _token = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
  
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConstants.register}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'email': data['email'] ?? email,
          'emailSent': data['emailSent'] ?? true,
        };
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConstants.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final token = data['token'];
        final user = data['user'];
        await persistSession(
          token: token,
          user: Map<String, dynamic>.from(user),
          rememberMe: rememberMe,
        );
        return {'success': true, 'user': user, 'token': token};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Login failed',
          'code': data['code'],
          'email': data['email'],
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConstants.verifyEmail}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Verification failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConstants.resendOtp}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Could not resend the code'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> getCurrentUser() async {
    if (_token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConstants.me}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        _currentUser = data['user'];
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get user'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
  }) async {
    if (_token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    try {
      final updates = <String, String>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;

      final response = await http.patch(
        Uri.parse('$_baseUrl${ApiConstants.updateProfile}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(updates),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        _currentUser = data['user'];
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Update failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_token == null) {
      return {'success': false, 'error': 'Not authenticated'};
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConstants.changePassword}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Password change failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConstants.forgotPassword}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Request failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
  
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConstants.resetPassword}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Reset failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> googleLogin({
    required String idToken,
    bool rememberMe = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConstants.google}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        final user = data['user'];
        await persistSession(
          token: token,
          user: Map<String, dynamic>.from(user),
          rememberMe: rememberMe,
        );
        return {'success': true, 'user': user, 'token': token};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Google sign-in failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  void logout() {
    unawaited(clearSession());
  }
}