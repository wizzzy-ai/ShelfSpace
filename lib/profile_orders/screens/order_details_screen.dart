import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/orders_provider.dart';
import '../utils/formatters.dart';
import '../widgets/order_status_chip.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final order =
        context.select<OrdersProvider, Order?>((p) => p.byId(orderId));

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: Text('Order not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.orderNumber}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Status',
            trailing: OrderStatusChip(status: order.status),
            children: [
              _StatusTracker(status: order.status),
              const SizedBox(height: 8),
              _InfoRow('Placed on', formatDate(order.placedAt)),
            ],
          ),
          _Section(
            title: 'Books purchased',
            children: [
              for (final item in order.items) _ItemRow(item: item),
              const Divider(height: 24),
              _InfoRow('Total', formatNaira(order.total), bold: true),
            ],
          ),
          _Section(
            title: 'Shipping address',
            children: [Text(order.shippingAddress.formatted)],
          ),
          _Section(
            title: 'Payment',
            children: [
              _InfoRow('Method', order.paymentMethod.display),
              _InfoRow('Status', order.paymentStatus.label),
            ],
          ),
          _Section(
            title: 'Delivery information',
            children: [_deliveryContent(order)],
          ),
          if (order.status.canCancel) ...[
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: () => _confirmCancel(context, order),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel order'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _deliveryContent(Order order) {
    final d = order.delivery;
    if (d.isEmpty) {
      return const Text('Delivery details will appear once your order ships.');
    }
    return Column(
      children: [
        if (d.courier != null) _InfoRow('Courier', d.courier!),
        if (d.trackingNumber != null) _InfoRow('Tracking no.', d.trackingNumber!),
        if (d.estimatedDelivery != null)
          _InfoRow('Estimated delivery', formatDate(d.estimatedDelivery!)),
        if (d.deliveredAt != null)
          _InfoRow('Delivered on', formatDate(d.deliveredAt!)),
      ],
    );
  }

  Future<void> _confirmCancel(BuildContext context, Order order) async {
    final orders = context.read<OrdersProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: Text('Order #${order.orderNumber} will be cancelled.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await orders.cancel(order.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Order cancelled' : orders.error ?? 'Could not cancel order',
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, this.trailing});

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
               ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.w700) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: style),
          const SizedBox(width: 16),
          Flexible(
            child: Text(value, textAlign: TextAlign.end, style: style),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(item.author, style: textTheme.bodySmall),
                Text('${item.quantity} × ${formatNaira(item.unitPrice)}',
                    style: textTheme.bodySmall),
              ],
            ),
          ),
          Text(formatNaira(item.lineTotal)),
        ],
      ),
    );
  }
}

class _StatusTracker extends StatelessWidget {
  const _StatusTracker({required this.status});

  final OrderStatus status;

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.processing,
    OrderStatus.shipped,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (status == OrderStatus.cancelled) {
      return Row(
        children: [
          Icon(Icons.cancel, color: scheme.error),
          const SizedBox(width: 8),
          const Text('This order was cancelled'),
        ],
      );
    }

    final current = _steps.indexOf(status);
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Icon(
                  i < current
                      ? Icons.check_circle
                      : i == current
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                  size: 20,
                  color: i <= current ? scheme.primary : scheme.outline,
                ),
                const SizedBox(width: 12),
                Text(
                  _steps[i].label,
                  style: TextStyle(
                    fontWeight:
                        i == current ? FontWeight.w700 : FontWeight.normal,
                    color: i > current ? scheme.outline : null,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
