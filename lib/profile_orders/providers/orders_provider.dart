import 'package:flutter/foundation.dart';

import '../data/profile_orders_repository.dart';
import '../models/models.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider(this._repository);

  final ProfileOrdersRepository _repository;

  List<Order> _orders = const [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Order? byId(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final fetched = await _repository.fetchOrders();
      // Newest first.
      _orders = [...fetched]..sort((a, b) => b.placedAt.compareTo(a.placedAt));
    } catch (_) {
      _error = 'Could not load your orders. Please try again.';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Returns true on success. On failure, [error] holds a user-facing message.
  Future<bool> cancel(String orderId) async {
    _error = null;
    try {
      final updated = await _repository.cancelOrder(orderId);
      _orders = [for (final o in _orders) o.id == orderId ? updated : o];
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Could not cancel this order.';
      notifyListeners();
      return false;
    }
  }
}
