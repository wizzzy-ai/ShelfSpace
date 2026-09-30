import '../models/models.dart';

/// The only thing the UI layer depends on. Swap the mock implementation for a
/// Firebase / REST implementation without touching providers or screens.
abstract class ProfileOrdersRepository {
  Future<UserProfile> fetchProfile();
  Future<UserProfile> updateProfile(UserProfile profile);
  Future<List<Order>> fetchOrders();
  Future<Order> cancelOrder(String orderId);
}
