import 'package:flutter/foundation.dart';

import '../models/order.dart';
import 'cart_service.dart';

class OrderService extends ChangeNotifier {
  OrderService._();

  static final OrderService instance = OrderService._();

  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  void createOrder({
    required String customerName,
    required String phone,
    required String address,
    required String city,
    required String paymentMethod,
  }) {
    final cart = CartService.instance;

    if (cart.items.isEmpty) {
      return;
    }

    final orderItems = cart.items.map((item) {
      return OrderItem(
        book: item.book,
        quantity: item.quantity,
        totalPrice: item.totalPrice,
      );
    }).toList();

    final order = Order(
      id: 'BIB-${DateTime.now().millisecondsSinceEpoch}',
      items: orderItems,
      subtotal: cart.subtotal,
      deliveryFee: cart.deliveryFee,
      total: cart.total,
      customerName: customerName,
      phone: phone,
      address: address,
      city: city,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      status: 'Processing',
    );

    _orders.insert(0, order);

    notifyListeners();
  }

  Order? getOrderById(String id) {
    for (final order in _orders) {
      if (order.id == id) {
        return order;
      }
    }

    return null;
  }

  void updateOrderStatus(String id, String status) {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index == -1) return;

    _orders[index] = _orders[index].copyWith(status: status);
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
