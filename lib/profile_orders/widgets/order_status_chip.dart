import 'package:flutter/material.dart';

import '../models/models.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  MaterialColor get _color => switch (status) {
        OrderStatus.pending => Colors.orange,
        OrderStatus.confirmed => Colors.blue,
        OrderStatus.processing => Colors.indigo,
        OrderStatus.shipped => Colors.teal,
        OrderStatus.outForDelivery => Colors.purple,
        OrderStatus.delivered => Colors.green,
        OrderStatus.cancelled => Colors.red,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _color.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
