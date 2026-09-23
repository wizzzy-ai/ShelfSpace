import 'package:flutter_test/flutter_test.dart';
import 'package:biblira/models/book.dart';
import 'package:biblira/services/book_repository.dart';
import 'package:biblira/services/cart_provider.dart';
import 'package:biblira/services/order_provider.dart';
import 'package:biblira/services/wishlist_provider.dart';
import 'package:biblira/models/order.dart';

void main() {
  group('BookRepository Tests', () {
    late BookRepository repo;

    setUp(() {
      repo = BookRepository();
    });

    test('initializes with rich catalog and categories', () {
      expect(repo.books.length, greaterThanOrEqualTo(5));
      expect(repo.categories.length, greaterThanOrEqualTo(5));
      expect(repo.featuredBooks.isNotEmpty, isTrue);
      expect(repo.bestsellerBooks.isNotEmpty, isTrue);
    });

    test('searchBooks filters by keyword correctly', () {
      final results = repo.searchBooks(query: 'Midnight Library');
      expect(results.length, 1);
      expect(results.first.title, 'The Midnight Library');
    });

    test('admin can add, update, and delete books', () {
      final initialCount = repo.books.length;
      final testBook = Book(
        id: 'test-book-999',
        title: 'Unit Test Book',
        author: 'Tester Author',
        description: 'Testing book repository CRUD.',
        coverUrl: 'https://example.com/cover.jpg',
        price: 15.00,
        categoryId: 'fiction',
        publicationDate: DateTime.now(),
      );

      // Add
      repo.addBook(testBook);
      expect(repo.books.length, initialCount + 1);
      expect(repo.getBookById('test-book-999')?.title, 'Unit Test Book');

      // Update
      final updatedBook = testBook.copyWith(price: 18.50);
      repo.updateBook(updatedBook);
      expect(repo.getBookById('test-book-999')?.price, 18.50);

      // Delete
      repo.deleteBook('test-book-999');
      expect(repo.books.length, initialCount);
      expect(repo.getBookById('test-book-999'), isNull);
    });
  });

  group('CartProvider Tests', () {
    late CartProvider cart;
    late Book sampleBook;

    setUp(() {
      cart = CartProvider();
      sampleBook = Book(
        id: 'book-sample',
        title: 'Sample Book',
        author: 'Author',
        description: 'Description',
        coverUrl: 'https://example.com/cover.jpg',
        price: 20.00,
        categoryId: 'fiction',
        publicationDate: DateTime.now(),
      );
    });

    test('adding items and calculating subtotal', () {
      cart.addItem(sampleBook, quantity: 2);
      expect(cart.itemCount, 2);
      expect(cart.subtotal, 40.00);
      expect(cart.isEmpty, isFalse);
    });

    test('applies promo code discount', () {
      cart.addItem(sampleBook, quantity: 2); // $40.00
      final applied = cart.applyPromoCode('BIBLIRA15'); // 15% off
      expect(applied, isTrue);
      expect(cart.discountAmount, 6.00);
    });

    test('delivery fee waived above free delivery threshold (\$50)', () {
      cart.addItem(sampleBook, quantity: 3); // $60.00
      expect(cart.hasFreeDelivery, isTrue);
      expect(cart.deliveryFee, 0.0);
    });
  });

  group('WishlistProvider Tests', () {
    late WishlistProvider wishlist;
    late Book sampleBook;

    setUp(() {
      wishlist = WishlistProvider();
      sampleBook = Book(
        id: 'book-wishlist',
        title: 'Wishlist Book',
        author: 'Author',
        description: 'Description',
        coverUrl: 'https://example.com/cover.jpg',
        price: 25.00,
        categoryId: 'fiction',
        publicationDate: DateTime.now(),
      );
    });

    test('toggle wishlist saves and removes book', () {
      expect(wishlist.isInWishlist(sampleBook.id), isFalse);

      wishlist.toggleWishlist(sampleBook);
      expect(wishlist.isInWishlist(sampleBook.id), isTrue);
      expect(wishlist.itemCount, 1);

      wishlist.toggleWishlist(sampleBook);
      expect(wishlist.isInWishlist(sampleBook.id), isFalse);
      expect(wishlist.itemCount, 0);
    });
  });

  group('OrderProvider Tests', () {
    late OrderProvider orderProvider;

    setUp(() {
      orderProvider = OrderProvider();
    });

    test('places order and updates tracking status', () {
      final initialCount = orderProvider.orders.length;
      final newOrder = orderProvider.createOrder(
        userId: 'test-user',
        cartItems: [],
        shippingAddress: ShippingAddress(
          id: 'addr1',
          fullName: 'Test User',
          street: '123 Test Street',
          city: 'New York',
          state: 'NY',
          zipCode: '10001',
          country: 'USA',
          phone: '+1 234 567 8900',
        ),
        paymentMethod: PaymentMethod(
          id: 'pm1',
          type: 'visa',
          last4: '4242',
        ),
      );

      expect(orderProvider.orders.length, initialCount + 1);
      expect(newOrder.status, OrderStatus.pending);

      // Advance order status
      orderProvider.updateOrderStatus(newOrder.id, OrderStatus.shipped);
      expect(orderProvider.getOrderById(newOrder.id)?.status, OrderStatus.shipped);
    });
  });
}
