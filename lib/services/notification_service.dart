import 'package:flutter/foundation.dart';

import '../models/book.dart';
import 'order_service.dart';
import 'wishlist_service.dart';

enum NotificationType {
  order,
  shipping,
  delivered,
  newArrival,
  wishlist,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String time;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    required this.isRead,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? time,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
    );
  }
}

class NotificationService extends ChangeNotifier {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount {
    return _notifications
        .where((notification) => !notification.isRead)
        .length;
  }

  bool get hasUnread => unreadCount > 0;

  Future<void> refresh({
    required List<Book> newArrivals,
  }) async {
    final liveNotifications = <AppNotification>[];

    for (final order in OrderService.instance.orders) {
      final statusValue = _normalizeStatus(order.status);
      final message = _buildOrderMessage(statusValue, order.id);
      final type = _resolveOrderType(statusValue);

      liveNotifications.add(
        AppNotification(
          id: 'order-${order.id}-$statusValue',
          title: _buildOrderTitle(statusValue),
          message: message,
          type: type,
          time: _timeAgo(order.createdAt),
          isRead: _isRead('order-${order.id}-$statusValue'),
        ),
      );
    }

    for (final book in newArrivals) {
      liveNotifications.add(
        AppNotification(
          id: 'new-arrival-${book.id}',
          title: 'New Arrival',
          message:
              'New books have arrived. Discover your next great read: ${book.title}.',
          type: NotificationType.newArrival,
          time: 'New in store',
          isRead: _isRead('new-arrival-${book.id}'),
        ),
      );
    }

    for (final book in WishlistService.instance.items) {
      liveNotifications.add(
        AppNotification(
          id: 'wishlist-${book.id}',
          title: 'Wishlist Reminder',
          message:
              'A book from your wishlist is still waiting for you: ${book.title}.',
          type: NotificationType.wishlist,
          time: 'In your wishlist',
          isRead: _isRead('wishlist-${book.id}'),
        ),
      );
    }

    _notifications
      ..clear()
      ..addAll(liveNotifications);

    notifyListeners();
  }

  bool _isRead(String id) {
    for (final notification in _notifications) {
      if (notification.id == id) {
        return notification.isRead;
      }
    }
    return false;
  }

  String _normalizeStatus(String status) {
    final normalized = status
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
    return normalized == 'paid' ? 'confirmed' : normalized;
  }

  String _buildOrderTitle(String status) {
    switch (status) {
      case 'pending':
        return 'Order Received';
      case 'confirmed':
        return 'Order Confirmed';
      case 'processing':
        return 'Order Processing';
      case 'shipped':
        return 'Your Order Has Shipped';
      case 'out for delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Order Delivered';
      default:
        return 'Order Update';
    }
  }

  String _buildOrderMessage(String status, String orderId) {
    switch (status) {
      case 'confirmed':
        return 'Your ShelfSpace order #$orderId has been confirmed and is being processed.';
      case 'pending':
        return 'Your ShelfSpace order #$orderId has been received and is waiting to be processed.';
      case 'processing':
        return 'Your ShelfSpace order #$orderId is being prepared for dispatch.';
      case 'shipped':
        return 'Your order #$orderId is on its way. Track your delivery from My Orders.';
      case 'out for delivery':
        return 'Your order #$orderId is out for delivery and should arrive soon.';
      case 'delivered':
        return 'Your ShelfSpace order #$orderId has been delivered. Enjoy your books!';
      default:
        return 'Your ShelfSpace order #$orderId has an update waiting for you.';
    }
  }

  NotificationType _resolveOrderType(String status) {
    switch (status) {
      case 'pending':
      case 'confirmed':
      case 'processing':
        return NotificationType.order;
      case 'shipped':
      case 'out for delivery':
        return NotificationType.shipping;
      case 'delivered':
        return NotificationType.delivered;
      default:
        return NotificationType.order;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
    return 'Recently';
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere(
      (notification) => notification.id == id,
    );

    if (index == -1) {
      return;
    }

    if (_notifications[index].isRead) {
      return;
    }

    _notifications[index] = _notifications[index].copyWith(
      isRead: true,
    );

    notifyListeners();
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(
        isRead: true,
      );
    }

    notifyListeners();
  }

  void addNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      time: 'Just now',
      isRead: false,
    );

    _notifications.insert(0, notification);

    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
