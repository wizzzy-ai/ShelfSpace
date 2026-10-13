import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/order.dart';
import '../../../services/order_service.dart';
import '../../auth/login_screen.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) OrderService.instance.loadAdminOrders();
    });
  }

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
          final error = OrderService.instance.error;
          final sessionExpired =
              error?.toLowerCase().contains('sign in again') ?? false;
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
              if (error != null)
                MaterialBanner(
                  content: Text(error),
                  actions: [
                    TextButton(
                      onPressed: sessionExpired
                          ? () => _openAdminSignIn(context)
                          : OrderService.instance.loadAdminOrders,
                      child: Text(sessionExpired ? 'Sign in' : 'Retry'),
                    ),
                  ],
                ),
              if (OrderService.instance.isLoading && orders.isEmpty)
                const LinearProgressIndicator(),
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
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: orders.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
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

void _openAdminSignIn(BuildContext context) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
}

class _AdminOrderCard extends StatelessWidget {
  final Order order;

  const _AdminOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
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
          Text(
            'Payment: ${order.displayPaymentStatus} · ${order.paymentMethod}',
            style: TextStyle(
              color: order.displayPaymentStatus == 'Paid'
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: order.displayPaymentStatus == 'Paid'
                  ? FontWeight.w600
                  : null,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${order.items.fold<int>(0, (sum, item) => sum + item.quantity)} items · ${_date(order.createdAt)}',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Status', style: TextStyle(fontSize: 12)),
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
                    _updateStatus(context, status);
                  }
                },
              ),
              if (order.status == 'Processing')
                FilledButton.tonalIcon(
                  onPressed: () => _updateStatus(context, 'Confirmed'),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Accept order'),
                ),
              if (order.status != 'Cancelled' &&
                  order.displayPaymentStatus != 'Paid' &&
                  order.displayPaymentStatus != 'Refunded')
                FilledButton.icon(
                  onPressed: () => _confirmPayment(context),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Confirm payment'),
                ),
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

  Future<void> _updateStatus(BuildContext context, String status) async {
    final updated = await OrderService.instance.updateOrderStatus(
      order.id,
      status,
    );
    if (!updated && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            OrderService.instance.error ?? 'Could not update this order.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmPayment(BuildContext context) async {
    final confirmed = await OrderService.instance.confirmPayment(order.id);
    if (!context.mounted) return;
    final error = OrderService.instance.error;
    if (!confirmed &&
        (error?.toLowerCase().contains('sign in again') ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error!),
          action: SnackBarAction(
            label: 'Sign in',
            onPressed: () => _openAdminSignIn(context),
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          confirmed
              ? 'Payment confirmed. Any uploaded ebooks in this order are now available in the customer library.'
              : error ?? 'Could not confirm payment.',
        ),
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
                _detail(context, 'Order ID', order.id),
                _detail(context, 'Customer', order.customerName),
                _detail(context, 'Phone', order.phone),
                _detail(
                  context,
                  'Delivery address',
                  '${order.address}, ${order.city}',
                ),
                _detail(context, 'Payment method', order.paymentMethod),
                _detail(context, 'Payment status', order.displayPaymentStatus),
                _detail(context, 'Order date', _date(order.createdAt)),
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
                _detail(context, 'Subtotal', _money(order.subtotal)),
                _detail(context, 'Delivery fee', _money(order.deliveryFee)),
                _detail(context, 'Total', _money(order.total), bold: true),
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

  Widget _detail(
    BuildContext context,
    String label,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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
