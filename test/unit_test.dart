import 'package:biblira/models/book.dart';
import 'package:biblira/services/cart_service.dart';
import 'package:biblira/services/mock_book_service.dart';
import 'package:biblira/services/order_service.dart';
import 'package:biblira/services/wishlist_service.dart';
import 'package:flutter_test/flutter_test.dart';

Book _sampleBook({String id = 'sample', double price = 20}) => Book(
      id: id,
      title: 'Sample Book',
      author: 'Test Author',
      genre: 'Fiction',
      description: 'A sample book for service tests.',
      coverUrl: 'https://example.com/cover.jpg',
      price: price,
      rating: 4.5,
      reviewCount: 12,
    );

void main() {
  group('MockBookService', () {
    test('provides featured, bestseller, and new arrival books', () {
      expect(MockBookService.books, isNotEmpty);
      expect(MockBookService.books.where((book) => book.isFeatured), isNotEmpty);
      expect(MockBookService.books.where((book) => book.isBestseller), isNotEmpty);
      expect(MockBookService.books.where((book) => book.isNewArrival), isNotEmpty);
    });
  });

  group('CartService', () {
    final cart = CartService.instance;
    final book = _sampleBook();

    setUp(() => cart.clear());

    test('adds books and calculates quantity and total', () {
      cart.add(book);
      cart.add(book);

      expect(cart.itemCount, 2);
      expect(cart.quantityFor(book), 2);
      expect(cart.subtotal, 40);
      expect(cart.total, 1540);
    });

    test('decreases quantity and removes the last copy', () {
      cart.add(book);
      cart.add(book);

      cart.decreaseQuantity(book);
      expect(cart.quantityFor(book), 1);

      cart.decreaseQuantity(book);
      expect(cart.contains(book), isFalse);
      expect(cart.deliveryFee, 0);
    });
  });

  group('WishlistService', () {
    final wishlist = WishlistService.instance;
    final book = _sampleBook(id: 'wishlist-book');

    setUp(() => wishlist.clear());

    test('toggle adds and removes a book', () {
      wishlist.toggle(book);
      expect(wishlist.contains(book), isTrue);
      expect(wishlist.items, hasLength(1));

      wishlist.toggle(book);
      expect(wishlist.contains(book), isFalse);
      expect(wishlist.items, isEmpty);
    });
  });

  group('OrderService', () {
    final cart = CartService.instance;
    final orders = OrderService.instance;

    setUp(() {
      cart.clear();
      orders.clearOrders();
    });

    test('creates an order from the cart and supports lookup', () {
      cart.add(_sampleBook(id: 'order-book', price: 25));

      orders.createOrder(
        customerName: 'Test User',
        phone: '+234 800 000 0000',
        address: '1 Test Street',
        city: 'Lagos',
        paymentMethod: 'Cash on delivery',
      );

      expect(orders.orders, hasLength(1));
      final order = orders.orders.single;
      expect(order.status, 'Processing');
      expect(order.total, 1525);
      expect(orders.getOrderById(order.id), same(order));
    });
  });
}
