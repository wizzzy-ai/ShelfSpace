import 'package:flutter_test/flutter_test.dart';
import 'package:biblira/models/book.dart';
import 'package:biblira/services/admin_user_service.dart';
import 'package:biblira/services/cart_service.dart';
import 'package:biblira/services/mock_book_service.dart';
import 'package:biblira/services/order_service.dart';

void main() {
  tearDown(() {
    CartService.instance.clear();
    OrderService.instance.clearOrders();
  });

  test('admin book CRUD updates the customer catalog', () {
    final service = MockBookService.instance;
    final initialCount = MockBookService.books.length;
    final book = Book(
      id: 'admin-test-book',
      title: 'Admin Test Book',
      author: 'ShelfSpace',
      genre: 'Testing',
      description: 'Catalog CRUD test',
      coverUrl: '',
      price: 1200,
      stock: 7,
      rating: 0,
      reviewCount: 0,
    );

    service.addBook(book);
    expect(MockBookService.books.length, initialCount + 1);

    service.updateBook(book.copyWith(price: 1800, stock: 2));
    final updated = MockBookService.books.singleWhere(
      (item) => item.id == book.id,
    );
    expect(updated.price, 1800);
    expect(updated.stock, 2);

    service.deleteBook(book.id);
    expect(MockBookService.books.length, initialCount);
    expect(MockBookService.books.any((item) => item.id == book.id), isFalse);
  });

  test('admin order status updates are shared with order history', () {
    final cart = CartService.instance;
    final orders = OrderService.instance;
    cart.add(MockBookService.books.first);
    orders.createOrder(
      customerName: 'Test Customer',
      phone: '+234 800 000 0000',
      address: '1 Test Street',
      city: 'Lagos',
      paymentMethod: 'Cash on Delivery',
    );

    final created = orders.orders.single;
    orders.updateOrderStatus(created.id, 'Shipped');

    expect(orders.getOrderById(created.id)?.status, 'Shipped');
  });

  test('local customer records can be disabled and re-enabled', () {
    final service = AdminUserService.instance;
    final user = service.users.first;

    service.setDisabled(user.id, true);
    expect(
      service.users.firstWhere((item) => item.id == user.id).isDisabled,
      isTrue,
    );

    service.setDisabled(user.id, false);
    expect(
      service.users.firstWhere((item) => item.id == user.id).isDisabled,
      isFalse,
    );
  });
}
