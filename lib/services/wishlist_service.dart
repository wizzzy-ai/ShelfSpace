import 'package:flutter/foundation.dart';

import '../models/book.dart';

class WishlistService extends ChangeNotifier {
  WishlistService._();

  static final WishlistService instance = WishlistService._();

  final List<Book> _items = [];

  List<Book> get items => List.unmodifiable(_items);

  bool contains(Book book) {
    return _items.any(
      (item) => item.id == book.id,
    );
  }

  void toggle(Book book) {
    if (contains(book)) {
      _items.removeWhere(
        (item) => item.id == book.id,
      );
    } else {
      _items.add(book);
    }

    notifyListeners();
  }

  void remove(Book book) {
    _items.removeWhere(
      (item) => item.id == book.id,
    );

    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}