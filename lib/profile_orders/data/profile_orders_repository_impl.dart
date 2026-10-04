import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../models/models.dart';
import 'profile_orders_repository.dart';

class ProfileOrdersRepositoryImpl implements ProfileOrdersRepository {
  ProfileOrdersRepositoryImpl({
    http.Client? client,
    AuthService? authService,
  })  : _client = client ?? http.Client(),
        _authService = authService ?? AuthService();

  final http.Client _client;
  final AuthService _authService;
  final String _baseUrl = ApiConstants.baseUrl;

  @override
  Future<UserProfile> fetchProfile() async {
    final token = _authService.token;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await _client.get(
      Uri.parse('$_baseUrl${ApiConstants.me}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch profile: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;

    return UserProfile(
      id: user['id'] as String? ?? '',
      name: user['name'] as String? ?? '',
      email: user['email'] as String? ?? '',
      phone: user['phone'] as String? ?? '',
      address: ShippingAddress(
        street: '', // Backend doesn't store address in user table
        city: '',
        state: '',
        country: '',
        postalCode: '',
      ),
      paymentMethod: PaymentMethod(
        type: PaymentType.card,
        last4: '4242',
      ),
    );
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    final token = _authService.token;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await _client.patch(
      Uri.parse('$_baseUrl${ApiConstants.updateProfile}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': profile.name,
        'phone': profile.phone,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;

    return UserProfile(
      id: user['id'] as String? ?? '',
      name: user['name'] as String? ?? '',
      email: user['email'] as String? ?? '',
      phone: user['phone'] as String? ?? '',
      address: profile.address,
      paymentMethod: profile.paymentMethod,
    );
  }

  @override
  Future<List<Order>> fetchOrders() async {
    final token = _authService.token;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await _client.get(
      Uri.parse('$_baseUrl${ApiConstants.orders}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch orders: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['items'] as List?) ?? [];

    return items.map((item) => _parseOrder(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<Order> cancelOrder(String orderId) async {
    // Backend doesn't have cancel endpoint yet, so we'll mock this
    // TODO: Implement when backend adds cancel endpoint
    throw UnimplementedError('Cancel order not implemented in backend yet');
  }

  Order _parseOrder(Map<String, dynamic> json) {
    final items = (json['items'] as List?) ?? [];
    final orderItems = items.map((item) {
      final itemData = item as Map<String, dynamic>;
      return OrderItem(
        title: itemData['title'] as String? ?? '',
        author: itemData['author'] as String? ?? '',
        quantity: (itemData['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: (itemData['unitPrice'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    return Order(
      id: json['id'] as String? ?? '',
      orderNumber: json['id'] as String? ?? '',
      placedAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      status: _parseOrderStatus(json['status'] as String? ?? ''),
      paymentStatus: PaymentStatus.paid, // Backend doesn't track payment status separately
      paymentMethod: PaymentMethod(
        type: PaymentType.card,
        last4: '4242',
      ),
      shippingAddress: ShippingAddress(
        street: json['address'] as String? ?? '',
        city: json['city'] as String? ?? '',
        state: '',
        country: 'Nigeria',
        postalCode: '',
      ),
      items: orderItems,
      delivery: DeliveryInfo(
        courier: 'GIG Logistics',
        estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
      ),
    );
  }

  OrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'processing':
        return OrderStatus.processing;
      case 'confirmed':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
