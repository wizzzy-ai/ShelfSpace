import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/order.dart';
import '../../../services/order_service.dart';

const _orderStatuses = [
  'Processing',
  'Confirmed',
  'Shipped',
  'Delivered',
  'Cancelled',
];

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All statuses';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Management')),
      body: AnimatedBuilder(
        animation: OrderService.instance,
        builder: (context, _) {
          final query = _searchController.text.trim().toLowerCase();
          final orders = OrderService.instance.orders.where((order) {
            final matchesQuery =
                query.isEmpty ||
                order.id.toLowerCase().contains(query) ||
                order.customerName.toLowerCase().contains(query) ||
                order.phone.toLowerCase().contains(query);
            final matchesStatus =
                _selectedStatus == 'All statuses' ||
                order.status == _selectedStatus;
            return matchesQuery && matchesStatus;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final search = TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search order ID, customer, or phone',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    );
                    final statusFilter = DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.filter_list_rounded),
                      ),
                      items: ['All statuses', ..._orderStatuses]
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (status) => setState(() {
                        _selectedStatus = status ?? 'All statuses';
                      }),
                    );
                    if (constraints.maxWidth >= 600) {
                      return Row(
                        children: [
                          Expanded(child: search),
                          const SizedBox(width: 12),
                          SizedBox(width: 220, child: statusFilter),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        search,
                        const SizedBox(height: 10),
                        statusFilter,
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: orders.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Text(
                            OrderService.instance.orders.isEmpty
                                ? 'Orders will appear here when customers check out.'
                                : 'No orders match your search or filter.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.mutedText),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _AdminOrderCard(order: orders[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final Order order;

  const _AdminOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(_money(order.total)),
              IconButton(
                tooltip: 'View order details',
                onPressed: () => _showDetails(context, order),
                icon: const Icon(Icons.open_in_new_rounded),
              ),
            ],
          ),
          Text(order.customerName),
          const SizedBox(height: 3),
          Text(
            '${order.items.fold<int>(0, (sum, item) => sum + item.quantity)} items · ${_date(order.createdAt)}',
            style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Status', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _orderStatuses.contains(order.status)
                    ? order.status
                    : 'Processing',
                items: _orderStatuses
                    .map(
                      (status) =>
                          DropdownMenuItem(value: status, child: Text(status)),
                    )
                    .toList(),
                onChanged: (status) {
                  if (status != null) {
                    OrderService.instance.updateOrderStatus(order.id, status);
                  }
                },
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showDetails(context, order),
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, Order order) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Order details'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detail('Order ID', order.id),
                _detail('Customer', order.customerName),
                _detail('Phone', order.phone),
                _detail('Delivery address', '${order.address}, ${order.city}'),
                _detail('Payment method', order.paymentMethod),
                _detail('Order date', _date(order.createdAt)),
                const Divider(height: 24),
                const Text(
                  'Items',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                for (final item in order.items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text('${item.book.title} × ${item.quantity}'),
                        ),
                        const SizedBox(width: 10),
                        Text(_money(item.totalPrice)),
                      ],
                    ),
                  ),
                const Divider(height: 24),
                _detail('Subtotal', _money(order.subtotal)),
                _detail('Delivery fee', _money(order.deliveryFee)),
                _detail('Total', _money(order.total), bold: true),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.mutedText),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
            ),
          ),
        ],
      ),
    );
  }
}

String _date(DateTime date) => DateFormat('dd MMM yyyy, HH:mm').format(date);

String _money(double amount) => NumberFormat.currency(
  locale: 'en_NG',
  symbol: '₦',
  decimalDigits: 0,
).format(amount);
