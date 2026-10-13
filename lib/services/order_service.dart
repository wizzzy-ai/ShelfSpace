import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/book.dart';
import '../models/order.dart';
import 'auth_service.dart';
import 'cart_service.dart';

class OrderService extends ChangeNotifier {
  OrderService._();

  static final OrderService instance = OrderService._();

  final List<Order> _orders = [];
  final AuthService _authService = AuthService();
  final http.Client _client = http.Client();
  final String _baseUrl = ApiConstants.baseUrl;

  bool _isLoading = false;
  String? _error;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCustomerOrders() async {
    final token = _authService.token;
    if (token == null) {
      _error = 'Sign in to view your orders.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl${ApiConstants.orders}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        throw Exception(data['error'] ?? 'Failed to load your orders');
      }
      final items = (data['items'] as List?) ?? [];
      _orders
        ..clear()
        ..addAll(
          items.map((item) => _parseOrder(item as Map<String, dynamic>)),
        );
    } catch (e) {
      _error = 'Failed to load your orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAdminOrders() async {
    await Future<void>.delayed(Duration.zero);

    final token = _authService.token;
    if (token == null) {
      _error =
          'Your admin session is no longer active. Sign in again, then retry.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl${ApiConstants.adminOrders}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          _authService.logout();
          _error = 'Your admin session is no longer active. Sign in again, then retry.';
          return;
        }
        throw Exception(data['error'] ?? 'Failed to load orders');
      }
      final items = (data['items'] as List?) ?? [];
      _orders
        ..clear()
        ..addAll(
          items.map((item) => _parseOrder(item as Map<String, dynamic>)),
        );
    } catch (e) {
      _error = 'Failed to load orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder({
    required String customerName,
    required String phone,
    required String address,
    required String city,
    required String paymentMethod,
  }) async {
    final token = _authService.token;
    if (token == null) {
      _error = 'Not authenticated';
      return false;
    }

    final cart = CartService.instance;

    if (cart.items.isEmpty) {
      _error = 'Cart is empty';
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl${ApiConstants.orders}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'customerName': customerName,
          'phone': phone,
          'address': address,
          'city': city,
          'paymentMethod': paymentMethod,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final orderData = data['order'] as Map<String, dynamic>;

        final order = _parseOrder(orderData);
        _orders.insert(0, order);

        // Clear cart after successful order
        await cart.clear();

        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to create order';
        return false;
      }
    } catch (e) {
      _error = 'Failed to create order: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Order? getOrderById(String id) {
    for (final order in _orders) {
      if (order.id == id) {
        return order;
      }
    }

    return null;
  }

  Future<bool> updateOrderStatus(String id, String status) async {
    final token = _authService.token;
    if (token == null) {
      _error = 'Sign in as an admin to update orders';
      notifyListeners();
      return false;
    }

    final index = _orders.indexWhere((order) => order.id == id);
    if (index == -1) {
      _error = 'Order is no longer in the list. Refresh and try again.';
      notifyListeners();
      return false;
    }

    try {
      final response = await _client.patch(
        Uri.parse('$_baseUrl${ApiConstants.adminOrders}/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          _authService.logout();
          _error = 'Your admin session is no longer active. Sign in again, then retry.';
          notifyListeners();
          return false;
        }
        throw Exception(data['error'] ?? 'Failed to update order');
      }
      _orders[index] = _parseOrder(data['order'] as Map<String, dynamic>);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update order: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmPayment(String id) async {
    final token = _authService.token;
    if (token == null) {
      _error =
          'Your admin session is no longer active. Sign in again, then retry.';
      notifyListeners();
      return false;
    }

    final index = _orders.indexWhere((order) => order.id == id);
    if (index == -1) {
      _error = 'Order is no longer in the list. Refresh and try again.';
      notifyListeners();
      return false;
    }

    try {
      final response = await _client.patch(
        Uri.parse('$_baseUrl${ApiConstants.adminOrders}/$id/payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '******',
        },
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          _authService.logout();
          _error = 'Your admin session is no longer active. Sign in again, then retry.';
          notifyListeners();
          return false;
        }
        throw Exception(data['error'] ?? 'Failed to confirm payment');
      }
      _orders[index] = _parseOrder(data['order'] as Map<String, dynamic>);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to confirm payment: $e';
      notifyListeners();
      return false;
    }
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  Order _parseOrder(Map<String, dynamic> json) {
    final items = (json['items'] as List?) ?? [];
    final orderItems = items.map((item) {
      final itemData = item as Map<String, dynamic>;
      return OrderItem(
        book: Book(
          id: itemData['bookId'] as String? ?? '',
          title: itemData['title'] as String? ?? '',
          author: itemData['author'] as String? ?? '',
          genre: '',
          description: '',
          coverUrl: itemData['coverUrl'] as String? ?? '',
          price: (itemData['unitPrice'] as num?)?.toDouble() ?? 0.0,
          stock: 0,
          rating: 0.0,
          reviewCount: 0,
        ),
        quantity: (itemData['quantity'] as num?)?.toInt() ?? 1,
        totalPrice: (itemData['totalPrice'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    return Order(
      id: json['id'] as String? ?? '',
      items: orderItems,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      customerName: json['customerName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      paymentStatus: json['paymentStatus'] as String? ?? 'Pending',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      status: json['status'] as String? ?? 'Processing',
    );
  }
}
