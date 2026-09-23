import 'package:flutter/foundation.dart';

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

  final List<AppNotification> _notifications = [
    const AppNotification(
      id: '1',
      title: 'Order Confirmed',
      message:
          'Your ShelfSpace order has been confirmed and is being processed.',
      type: NotificationType.order,
      time: '2 min ago',
      isRead: false,
    ),
    const AppNotification(
      id: '2',
      title: 'New Arrival',
      message:
          'New books have arrived. Discover your next great read.',
      type: NotificationType.newArrival,
      time: '1 hour ago',
      isRead: false,
    ),
    const AppNotification(
      id: '3',
      title: 'Your Order Has Shipped',
      message:
          'Your order is on its way. Track your delivery from My Orders.',
      type: NotificationType.shipping,
      time: 'Yesterday',
      isRead: true,
    ),
    const AppNotification(
      id: '4',
      title: 'Wishlist Reminder',
      message:
          'A book from your wishlist is still waiting for you.',
      type: NotificationType.wishlist,
      time: '2 days ago',
      isRead: true,
    ),
    const AppNotification(
      id: '5',
      title: 'Order Delivered',
      message:
          'Your ShelfSpace order has been delivered. Enjoy your books!',
      type: NotificationType.delivered,
      time: '4 days ago',
      isRead: true,
    ),
  ];

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);

  int get unreadCount {
    return _notifications
        .where((notification) => !notification.isRead)
        .length;
  }

  bool get hasUnread => unreadCount > 0;

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