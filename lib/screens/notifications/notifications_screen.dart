import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/book.dart';
import '../../services/auth_service.dart';
import '../../services/book_service.dart';
import '../../services/notification_service.dart';
import '../../services/order_service.dart';
import '../../services/wishlist_service.dart';
import '../home/home_screen.dart';
import '../orders/orders_screen.dart';
import '../wishlist/wishlist_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final errors = <String>[];
      if (AuthService().token != null) {
        await Future.wait([
          OrderService.instance.loadCustomerOrders(),
          WishlistService.instance.load(),
        ]);

        errors.addAll([
          OrderService.instance.error,
          WishlistService.instance.error,
        ].whereType<String>());
      }

      var newArrivals = <Book>[];
      try {
        newArrivals = await BookService().fetchNewArrivals(limit: 5);
      } catch (error) {
        errors.add('Could not load new arrivals: $error');
      }

      await NotificationService.instance.refresh(
        newArrivals: newArrivals,
      );
      if (errors.isNotEmpty) {
        throw StateError(errors.join('\n'));
      }
    } catch (error) {
      _loadError = 'Unable to load notifications: $error';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openNotification(
    BuildContext context,
    AppNotification notification,
  ) {
    NotificationService.instance.markAsRead(notification.id);

    switch (notification.type) {
      case NotificationType.order:
      case NotificationType.shipping:
      case NotificationType.delivered:
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const OrdersScreen(),
          ),
        );
        break;
      case NotificationType.newArrival:
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => HomeScreen(onSearchTap: () {}),
          ),
        );
        break;
      case NotificationType.wishlist:
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const WishlistScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text('Notifications'),
        actions: [
          AnimatedBuilder(
            animation: NotificationService.instance,
            builder: (context, _) {
              if (!NotificationService.instance.hasUnread) {
                return const SizedBox.shrink();
              }

              return TextButton(
                onPressed: () {
                  NotificationService.instance.markAllAsRead();
                },
                child: const Text(
                  'Mark all read',
                  style: TextStyle(
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Refresh notifications',
            onPressed: _isLoading ? null : _loadNotifications,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: AnimatedBuilder(
        animation: NotificationService.instance,
        builder: (context, _) {
          final notifications =
              NotificationService.instance.notifications;

          if (_isLoading && notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_loadError != null && notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadNotifications,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              if (_loadError != null)
                MaterialBanner(
                  content: Text(_loadError!),
                  actions: [
                    TextButton(
                      onPressed: _loadNotifications,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    24,
                  ),
                  itemCount: notifications.length,
                  separatorBuilder: (_, _) {
                    return const SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    final notification = notifications[index];

                    return _NotificationCard(
                      notification: notification,
                      onTap: () {
                        _openNotification(
                          context,
                          notification,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.burgundy.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.burgundy,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'You are all caught up. New updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: notification.isRead
          ? AppColors.white
          : AppColors.burgundy.withValues(
              alpha: 0.05,
            ),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead
                  ? Theme.of(context).colorScheme.outlineVariant
                  : AppColors.burgundy.withValues(
                      alpha: 0.25,
                    ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(
                type: notification.type,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(
                              top: 5,
                              left: 8,
                            ),
                            decoration:
                                const BoxDecoration(
                              color: AppColors.burgundy,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.time,
                      style: TextStyle(
                        color: notification.isRead
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : AppColors.burgundy,
                        fontSize: 11,
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final NotificationType type;

  const _NotificationIcon({
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (type) {
      case NotificationType.order:
        icon = Icons.receipt_long_outlined;
        break;

      case NotificationType.shipping:
        icon = Icons.local_shipping_outlined;
        break;

      case NotificationType.delivered:
        icon = Icons.check_circle_outline_rounded;
        break;

      case NotificationType.newArrival:
        icon = Icons.auto_stories_outlined;
        break;

      case NotificationType.wishlist:
        icon = Icons.favorite_border_rounded;
        break;
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.burgundy.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        icon,
        color: AppColors.burgundy,
        size: 22,
      ),
    );
  }
}