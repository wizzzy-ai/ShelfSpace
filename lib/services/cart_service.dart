import 'package:flutter/foundation.dart';

import '../models/book.dart';

class CartItem {
  final Book book;
  int quantity;

  CartItem({
    required this.book,
    this.quantity = 1,
  });

  double get totalPrice => book.price * quantity;
}

class CartService extends ChangeNotifier {
  CartService._();

  static final CartService instance = CartService._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount {
    return _items.fold(
      0,
      (total, item) => total + item.quantity,
    );
  }

  double get subtotal {
    return _items.fold(
      0,
      (total, item) => total + item.totalPrice,
    );
  }

  double get deliveryFee {
    return _items.isEmpty ? 0 : 1500;
  }

  double get total {
    return subtotal + deliveryFee;
  }

  bool contains(Book book) {
    return _items.any(
      (item) => item.book.id == book.id,
    );
  }

  int quantityFor(Book book) {
    final index = _items.indexWhere(
      (item) => item.book.id == book.id,
    );

    if (index == -1) {
      return 0;
    }

    return _items[index].quantity;
  }

  void add(Book book) {
    final index = _items.indexWhere(
      (item) => item.book.id == book.id,
    );

    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(
        CartItem(book: book),
      );
    }

    notifyListeners();
  }

  void remove(Book book) {
    _items.removeWhere(
      (item) => item.book.id == book.id,
    );

    notifyListeners();
  }

  void increaseQuantity(Book book) {
    final index = _items.indexWhere(
      (item) => item.book.id == book.id,
    );

    if (index == -1) return;

    _items[index].quantity++;
    notifyListeners();
  }

  void decreaseQuantity(Book book) {
    final index = _items.indexWhere(
      (item) => item.book.id == book.id,
    );

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}