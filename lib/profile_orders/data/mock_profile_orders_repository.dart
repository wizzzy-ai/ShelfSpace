import '../models/models.dart';
import 'profile_orders_repository.dart';

/// In-memory implementation with sample data, for development and demos.
class MockProfileOrdersRepository implements ProfileOrdersRepository {
  static const _latency = Duration(milliseconds: 600);

  UserProfile _profile = const UserProfile(
    id: 'u1',
    name: 'Ada Okafor',
    email: 'ada@example.com',
    phone: '+2348012345678',
    address: ShippingAddress(
      street: '12 Admiralty Way, Lekki Phase 1',
      city: 'Lagos',
      state: 'Lagos',
      country: 'Nigeria',
      postalCode: '106104',
    ),
    paymentMethod: PaymentMethod(type: PaymentType.card, last4: '4242'),
  );

  late final List<Order> _orders = _seedOrders();

  @override
  Future<UserProfile> fetchProfile() async {
    await Future<void>.delayed(_latency);
    return _profile;
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    await Future<void>.delayed(_latency);
    _profile = profile;
    return _profile;
  }

  @override
  Future<List<Order>> fetchOrders() async {
    await Future<void>.delayed(_latency);
    return List.unmodifiable(_orders);
  }

  @override
  Future<Order> cancelOrder(String orderId) async {
    await Future<void>.delayed(_latency);
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) throw StateError('Order not found');
    final order = _orders[index];
    if (!order.status.canCancel) {
      throw StateError('This order can no longer be cancelled');
    }
    final updated = order.copyWith(
      status: OrderStatus.cancelled,
      paymentStatus: order.paymentStatus == PaymentStatus.paid
          ? PaymentStatus.refunded
          : order.paymentStatus,
    );
    _orders[index] = updated;
    return updated;
  }

  List<Order> _seedOrders() {
    final now = DateTime.now();
    const address = ShippingAddress(
      street: '12 Admiralty Way, Lekki Phase 1',
      city: 'Lagos',
      state: 'Lagos',
      country: 'Nigeria',
      postalCode: '106104',
    );
    const card = PaymentMethod(type: PaymentType.card, last4: '4242');

    return [
      Order(
        id: 'o1001',
        orderNumber: '1001',
        placedAt: now.subtract(const Duration(days: 1)),
        status: OrderStatus.processing,
        paymentStatus: PaymentStatus.paid,
        paymentMethod: card,
        shippingAddress: address,
        items: const [
          OrderItem(title: 'Things Fall Apart', author: 'Chinua Achebe', quantity: 1, unitPrice: 15000),
          OrderItem(title: 'Half of a Yellow Sun', author: 'Chimamanda Ngozi Adichie', quantity: 1, unitPrice: 12000),
          OrderItem(title: 'Purple Hibiscus', author: 'Chimamanda Ngozi Adichie', quantity: 1, unitPrice: 15000),
        ],
        delivery: DeliveryInfo(
          courier: 'GIG Logistics',
          estimatedDelivery: now.add(const Duration(days: 3)),
        ),
      ),
      Order(
        id: 'o1002',
        orderNumber: '1002',
        placedAt: now.subtract(const Duration(days: 9)),
        status: OrderStatus.delivered,
        paymentStatus: PaymentStatus.paid,
        paymentMethod: card,
        shippingAddress: address,
        items: const [
          OrderItem(title: 'Americanah', author: 'Chimamanda Ngozi Adichie', quantity: 2, unitPrice: 14000),
        ],
        delivery: DeliveryInfo(
          courier: 'GIG Logistics',
          trackingNumber: 'GIG-77120934',
          deliveredAt: now.subtract(const Duration(days: 5)),
        ),
      ),
      Order(
        id: 'o1003',
        orderNumber: '1003',
        placedAt: now.subtract(const Duration(hours: 3)),
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.pending,
        paymentMethod: const PaymentMethod(type: PaymentType.payOnDelivery),
        shippingAddress: address,
        items: const [
          OrderItem(title: 'The Fishermen', author: 'Chigozie Obioma', quantity: 1, unitPrice: 11000),
        ],
      ),
    ];
  }
}
