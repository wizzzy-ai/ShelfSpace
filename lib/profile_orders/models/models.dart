// Domain models for the Profile & Orders module.

enum OrderStatus {
  pending('Pending'),
  confirmed('Confirmed'),
  processing('Processing'),
  shipped('Shipped'),
  outForDelivery('Out for Delivery'),
  delivered('Delivered'),
  cancelled('Cancelled');

  const OrderStatus(this.label);
  final String label;

  /// Customers may only cancel before the order starts processing.
  bool get canCancel => this == pending || this == confirmed;
}

enum PaymentStatus {
  pending('Pending'),
  paid('Paid'),
  failed('Failed'),
  refunded('Refunded');

  const PaymentStatus(this.label);
  final String label;
}

enum PaymentType {
  card('Card'),
  bankTransfer('Bank Transfer'),
  payOnDelivery('Pay on Delivery');

  const PaymentType(this.label);
  final String label;
}

class ShippingAddress {
  const ShippingAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });

  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  String get formatted => '$street\n$city, $state $postalCode\n$country';
}

/// Never store full card numbers in the app. Keep only a token or the last
/// four digits returned by your payment provider.
class PaymentMethod {
  const PaymentMethod({required this.type, this.last4});

  final PaymentType type;
  final String? last4;

  String get display {
    if (type == PaymentType.card && last4 != null && last4!.isNotEmpty) {
      return 'Card •••• $last4';
    }
    return type.label;
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.paymentMethod,
    this.profileImagePath,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImagePath;
  final ShippingAddress address;
  final PaymentMethod paymentMethod;
}

class OrderItem {
  const OrderItem({
    required this.title,
    required this.author,
    required this.quantity,
    required this.unitPrice,
  });

  final String title;
  final String author;
  final int quantity;

  /// Price in naira.
  final int unitPrice;

  int get lineTotal => quantity * unitPrice;
}

class DeliveryInfo {
  const DeliveryInfo({
    this.courier,
    this.trackingNumber,
    this.estimatedDelivery,
    this.deliveredAt,
  });

  final String? courier;
  final String? trackingNumber;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredAt;

  bool get isEmpty =>
      courier == null &&
      trackingNumber == null &&
      estimatedDelivery == null &&
      deliveredAt == null;
}

class Order {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.placedAt,
    required this.items,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.shippingAddress,
    this.delivery = const DeliveryInfo(),
  });

  final String id;
  final String orderNumber;
  final DateTime placedAt;
  final List<OrderItem> items;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final PaymentMethod paymentMethod;
  final ShippingAddress shippingAddress;
  final DeliveryInfo delivery;

  int get totalBooks => items.fold(0, (sum, i) => sum + i.quantity);
  int get total => items.fold(0, (sum, i) => sum + i.lineTotal);

  Order copyWith({OrderStatus? status, PaymentStatus? paymentStatus}) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      placedAt: placedAt,
      items: items,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod,
      shippingAddress: shippingAddress,
      delivery: delivery,
    );
  }
}
