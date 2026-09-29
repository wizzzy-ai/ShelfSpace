import 'package:flutter/foundation.dart';

import '../data/profile_orders_repository.dart';
import '../models/models.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repository);

  final ProfileOrdersRepository _repository;

  UserProfile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repository.fetchProfile();
    } catch (_) {
      _error = 'Could not load your profile. Please try again.';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Returns true on success. On failure, [error] holds a user-facing message.
  Future<bool> save(UserProfile updated) async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repository.updateProfile(updated);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Could not save your changes. Please try again.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
