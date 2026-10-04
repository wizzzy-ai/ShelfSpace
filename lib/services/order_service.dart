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
    // This would be an admin function, not available to regular users
    // For now, just update locally
    final index = _orders.indexWhere((order) => order.id == id);
    if (index == -1) return false;

    _orders[index] = _orders[index].copyWith(status: status);
    notifyListeners();
    return true;
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
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      status: json['status'] as String? ?? 'Processing',
    );
  }
}
