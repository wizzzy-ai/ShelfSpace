import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/orders_provider.dart';
import '../utils/formatters.dart';
import '../widgets/order_status_chip.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: Builder(
        builder: (context) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null && provider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: provider.load,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: provider.load,
            child: provider.orders.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 160),
                      Center(child: Text('You have no orders yet.')),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),                    itemBuilder: (context, index) =>
                        _OrderCard(order: provider.orders[index]),
                  ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final count = order.totalBooks;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => OrderDetailsScreen(orderId: order.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order.orderNumber}',
                        style: textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('$count ${count == 1 ? 'Book' : 'Books'}'),
                    Text(
                      formatNaira(order.total),
                      style: textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(formatDate(order.placedAt), style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OrderStatusChip(status: order.status),
            ],
          ),
        ),
      ),
    );
  }
}
