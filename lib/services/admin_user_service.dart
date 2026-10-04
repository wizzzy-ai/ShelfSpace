import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import 'auth_service.dart';

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime joinedAt;
  final bool isDisabled;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.joinedAt,
    this.isDisabled = false,
  });

  AdminUser copyWith({bool? isDisabled}) {
    return AdminUser(
      id: id,
      name: name,
      email: email,
      phone: phone,
      joinedAt: joinedAt,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      joinedAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      isDisabled: json['disabled'] as bool? ?? false,
    );
  }
}

class AdminUserService extends ChangeNotifier {
  AdminUserService._();

  static final AdminUserService instance = AdminUserService._();

  final List<AdminUser> _users = [];
  final AuthService _authService = AuthService();
  final http.Client _client = http.Client();
  final String _baseUrl = ApiConstants.baseUrl;

  bool _isLoading = false;
  String? _error;

  List<AdminUser> get users => List.unmodifiable(_users);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get activeCount => _users.where((user) => !user.isDisabled).length;

  Future<void> load({String? query}) async {
    final token = _authService.token;
    if (token == null) {
      _error = 'Not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$_baseUrl${ApiConstants.adminUsers}').replace(
        queryParameters: {
          if (query != null && query.isNotEmpty) 'q': query,
        },
      );

      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = (data['items'] as List?) ?? [];
        
        _users.clear();
        for (final item in items) {
          _users.add(AdminUser.fromJson(item as Map<String, dynamic>));
        }
      } else if (response.statusCode == 403) {
        _error = 'Admin access required';
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to load users';
      }
    } catch (e) {
      _error = 'Failed to load users: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setDisabled(String id, bool disabled) async {
    final token = _authService.token;
    if (token == null) {
      _error = 'Not authenticated';
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.patch(
        Uri.parse('$_baseUrl${ApiConstants.adminUsers}/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'disabled': disabled}),
      );

      if (response.statusCode == 200) {
        // Update local list
        final index = _users.indexWhere((user) => user.id == id);
        if (index != -1) {
          _users[index] = _users[index].copyWith(isDisabled: disabled);
        }
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to update user status';
        return false;
      }
    } catch (e) {
      _error = 'Failed to update user status: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String id) async {
    final token = _authService.token;
    if (token == null) {
      _error = 'Not authenticated';
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl${ApiConstants.adminUsers}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        _users.removeWhere((user) => user.id == id);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to delete user';
        return false;
      }
    } catch (e) {
      _error = 'Failed to delete user: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
