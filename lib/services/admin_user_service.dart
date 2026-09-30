import 'package:flutter/foundation.dart';

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
}

class AdminUserService extends ChangeNotifier {
  AdminUserService._();

  static final AdminUserService instance = AdminUserService._();

  final List<AdminUser> _users = [
    AdminUser(
      id: 'customer-001',
      name: 'Amara Okafor',
      email: 'amara@example.com',
      phone: '+234 801 234 5678',
      joinedAt: DateTime(2025, 11, 4),
    ),
    AdminUser(
      id: 'customer-002',
      name: 'Tunde Adeyemi',
      email: 'tunde@example.com',
      phone: '+234 802 345 6789',
      joinedAt: DateTime(2026, 1, 19),
    ),
    AdminUser(
      id: 'customer-003',
      name: 'Zainab Bello',
      email: 'zainab@example.com',
      phone: '+234 803 456 7890',
      joinedAt: DateTime(2026, 3, 8),
    ),
  ];

  List<AdminUser> get users => List.unmodifiable(_users);

  int get activeCount => _users.where((user) => !user.isDisabled).length;

  void setDisabled(String id, bool disabled) {
    final index = _users.indexWhere((user) => user.id == id);
    if (index == -1) return;

    _users[index] = _users[index].copyWith(isDisabled: disabled);
    notifyListeners();
  }

  void deleteUser(String id) {
    final index = _users.indexWhere((user) => user.id == id);
    if (index == -1) return;

    _users.removeAt(index);
    notifyListeners();
  }
}
