import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../models/book.dart';
import '../../models/order.dart';
import '../../services/admin_user_service.dart';
import '../../services/mock_book_service.dart';
import '../../services/order_service.dart';
import 'books/admin_books_screen.dart';
import 'orders/admin_orders_screen.dart';
import 'users/admin_users_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          MockBookService.instance,
          OrderService.instance,
          AdminUserService.instance,
        ]),
        builder: (context, _) {
          final books = MockBookService.books;
          final orders = OrderService.instance.orders;
          final users = AdminUserService.instance.users;
          final lowStock = books.where((book) => book.stock < 5).toList();
          final revenue = orders
              .where((order) => order.status != 'Cancelled')
              .fold<double>(0, (sum, order) => sum + order.total);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final horizontalPadding = isWide ? 28.0 : 18.0;
              final content = SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Local admin workspace · demo data',
                      style: TextStyle(color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 22),
                    _buildStats(
                      constraints.maxWidth - horizontalPadding * 2,
                      books.length,
                      users.length,
                      orders.length,
                      revenue,
                    ),
                    const SizedBox(height: 28),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildRecentOrders(context, orders),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: _buildLowStock(context, lowStock),
                          ),
                        ],
                      )
                    else ...[
                      _buildRecentOrders(context, orders),
                      const SizedBox(height: 24),
                      _buildLowStock(context, lowStock),
                    ],
                    const SizedBox(height: 28),
                    _buildQuickActions(context),
                  ],
                ),
              );

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: content,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStats(
    double maxWidth,
    int bookCount,
    int userCount,
    int orderCount,
    double revenue,
  ) {
    final columns = maxWidth >= 820 ? 4 : 2;
    final gap = 12.0;
    final width = (maxWidth - gap * (columns - 1)) / columns;
    final stats = [
      _DashboardStat('Total Books', '$bookCount', Icons.menu_book_outlined),
      _DashboardStat('Total Users', '$userCount', Icons.people_outline),
      _DashboardStat(
        'Total Orders',
        '$orderCount',
        Icons.receipt_long_outlined,
      ),
      _DashboardStat('Total Revenue', _money(revenue), Icons.payments_outlined),
    ];

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [for (final stat in stats) _StatCard(stat: stat, width: width)],
    );
  }

  Widget _buildRecentOrders(BuildContext context, List<Order> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: 'Recent Orders',
          actionLabel: 'View all',
          onAction: () => _open(context, const AdminOrdersScreen()),
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          const _EmptyPanel(message: 'Orders will appear here when placed.')
        else
          ...orders
              .take(5)
              .map(
                (order) => _RecentOrderRow(
                  order: order,
                  onTap: () => _open(context, const AdminOrdersScreen()),
                ),
              ),
      ],
    );
  }

  Widget _buildLowStock(BuildContext context, List<Book> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: 'Low Stock',
          actionLabel: 'Manage books',
          onAction: () => _open(context, const AdminBooksScreen()),
        ),
        const SizedBox(height: 12),
        if (books.isEmpty)
          const _EmptyPanel(message: 'No books below the 5-copy threshold.')
        else
          ...books.map(
            (book) => _LowStockRow(
              book: book,
              onTap: () => _open(context, const AdminBooksScreen()),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    const actions = [
      _QuickAction(
        'Manage Books',
        Icons.menu_book_outlined,
        AdminBooksScreen(),
      ),
      _QuickAction(
        'Manage Orders',
        Icons.receipt_long_outlined,
        AdminOrdersScreen(),
      ),
      _QuickAction('Manage Users', Icons.people_outline, AdminUsersScreen()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final action in actions)
              OutlinedButton.icon(
                onPressed: () => _open(context, action.screen),
                icon: Icon(action.icon),
                label: Text(action.label),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _DashboardStat {
  final String label;
  final String value;
  final IconData icon;

  const _DashboardStat(this.label, this.value, this.icon);
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Widget screen;

  const _QuickAction(this.label, this.icon, this.screen);
}

class _StatCard extends StatelessWidget {
  final _DashboardStat stat;
  final double width;

  const _StatCard({required this.stat, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        constraints: const BoxConstraints(minHeight: 114),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(stat.icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              stat.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              stat.label,
              style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeading({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String message;

  const _EmptyPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(message, style: const TextStyle(color: AppColors.mutedText)),
    );
  }
}

class _RecentOrderRow extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _RecentOrderRow({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      tileColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      leading: const Icon(
        Icons.receipt_long_outlined,
        color: AppColors.burgundy,
      ),
      title: Text(order.id, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(order.customerName),
      trailing: Text(
        _money(order.total),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _LowStockRow extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _LowStockRow({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      tileColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      leading: const Icon(Icons.warning_amber_rounded, color: AppColors.error),
      title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        book.stock == 0 ? 'Out of stock' : 'Only ${book.stock} left',
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

String _money(double amount) => NumberFormat.currency(
  locale: 'en_NG',
  symbol: '₦',
  decimalDigits: 0,
).format(amount);
