import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  void _openNotification(
    BuildContext context,
    AppNotification notification,
  ) {
    NotificationService.instance.markAsRead(notification.id);

    String message;

    switch (notification.type) {
      case NotificationType.order:
        message = 'Opening your order...';
        break;

      case NotificationType.shipping:
        message = 'Opening delivery tracking...';
        break;

      case NotificationType.delivered:
        message = 'Opening delivered order...';
        break;

      case NotificationType.newArrival:
        message = 'Opening new arrivals...';
        break;

      case NotificationType.wishlist:
        message = 'Opening your wishlist...';
        break;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
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
          const SizedBox(width: 6),
        ],
      ),
      body: AnimatedBuilder(
        animation: NotificationService.instance,
        builder: (context, _) {
          final notifications =
              NotificationService.instance.notifications;

          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
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