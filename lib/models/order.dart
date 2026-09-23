import 'book.dart';

class OrderItem {
  final Book book;
  final int quantity;
  final double totalPrice;

  const OrderItem({
    required this.book,
    required this.quantity,
    required this.totalPrice,
  });
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String customerName;
  final String phone;
  final String address;
  final String city;
  final String paymentMethod;
  final DateTime createdAt;
  final String status;

  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.city,
    required this.paymentMethod,
    required this.createdAt,
    this.status = 'Processing',
  });
}