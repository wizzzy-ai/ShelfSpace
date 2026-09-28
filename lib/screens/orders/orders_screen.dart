import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppColors.cream,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: OrderService.instance,
        builder: (context, _) {
          final orders = OrderService.instance.orders;

          if (orders.isEmpty) {
            return const _EmptyOrders();
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              28,
            ),
            itemCount: orders.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];

              return _OrderCard(
                order: order,
                onTap: () {
                  _showOrderDetails(
                    context,
                    order,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showOrderDetails(
    BuildContext context,
    Order order,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      builder: (sheetContext) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.92,
            child: _OrderDetailsSheet(
              order: order,
            ),
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = order.items.fold<int>(
      0,
      (total, item) => total + item.quantity,
    );

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.burgundy.withValues(
                        alpha: 0.08,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.burgundy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order.createdAt),
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(
                    status: order.status,
                  ),
                ],
              ),

              const SizedBox(height: 15),

              const Divider(
                color: AppColors.border,
                height: 1,
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Text(
                    '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₦${order.total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.burgundy,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.mutedText,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final Order order;

  const _OrderDetailsSheet({
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order Details',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                _StatusBadge(
                  status: order.status,
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              order.id,
              style: const TextStyle(
                color: AppColors.mutedText,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 20),

            _buildTrackingCard(),

            const SizedBox(height: 20),

            const Text(
              'Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Column(
                children: order.items.map(
                  (item) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(9),
                            child: Image.network(
                              item.book.coverUrl,
                              width: 54,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, _, _) {
                                return Container(
                                  width: 54,
                                  height: 70,
                                  color: AppColors.border,
                                  child: const Icon(
                                    Icons
                                        .menu_book_rounded,
                                    color:
                                        AppColors.mutedText,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.book.title,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Qty: ${item.quantity}',
                                  style: const TextStyle(
                                    color:
                                        AppColors.mutedText,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '₦${item.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.burgundy,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Payment & Delivery',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Payment',
                    value: order.paymentMethod,
                  ),
                  _InfoRow(
                    label: 'Name',
                    value: order.customerName,
                  ),
                  _InfoRow(
                    label: 'Phone',
                    value: order.phone,
                  ),
                  _InfoRow(
                    label: 'Address',
                    value:
                        '${order.address}, ${order.city}',
                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Subtotal',
                    value:
                        '₦${order.subtotal.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 9),
                  _SummaryRow(
                    label: 'Delivery',
                    value:
                        '₦${order.deliveryFee.toStringAsFixed(0)}',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: Divider(
                      color: AppColors.border,
                    ),
                  ),
                  _SummaryRow(
                    label: 'Total',
                    value:
                        '₦${order.total.toStringAsFixed(0)}',
                    isTotal: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingCard() {
    final steps = [
      'Processing',
      'Shipped',
      'Out for Delivery',
      'Delivered',
    ];

    final currentIndex = steps.indexOf(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Status',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(
            steps.length,
            (index) {
              final isCompleted =
                  index <= currentIndex;
              final isLast =
                  index == steps.length - 1;

              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.burgundy
                              : AppColors.border,
                          shape: BoxShape.circle,
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color:
                                    AppColors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 30,
                          color: index < currentIndex
                              ? AppColors.burgundy
                              : AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 3),
                    child: Text(
                      steps[index],
                      style: TextStyle(
                        color: isCompleted
                            ? AppColors.dark
                            : AppColors.mutedText,
                        fontWeight: isCompleted
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _InfoRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 9,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            color: AppColors.border,
            height: 1,
          ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal
                ? AppColors.dark
                : AppColors.mutedText,
            fontSize: isTotal ? 16 : 13,
            fontWeight:
                isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: isTotal
                ? AppColors.burgundy
                : AppColors.dark,
            fontSize: isTotal ? 18 : 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (status) {
      case 'Shipped':
        background =
            AppColors.burgundy.withValues(alpha: 0.10);
        foreground = AppColors.burgundy;
        break;

      case 'Out for Delivery':
        background =
            Colors.orange.withValues(alpha: 0.10);
        foreground = Colors.orange.shade800;
        break;

      case 'Delivered':
        background =
            AppColors.success.withValues(alpha: 0.10);
        foreground = AppColors.success;
        break;

      default:
        background =
            AppColors.brown.withValues(alpha: 0.10);
        foreground = AppColors.brown;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.burgundy.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.burgundy,
                size: 46,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No orders yet',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your completed and active orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedText,
                height: 1.5,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}