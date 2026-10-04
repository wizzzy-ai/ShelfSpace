import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/book.dart';
import 'auth_service.dart';

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
  final AuthService _authService = AuthService();
  final http.Client _client = http.Client();
  final String _baseUrl = ApiConstants.baseUrl;

  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<void> load() async {
    final token = _authService.token;
    if (token == null) {
      _items.clear();
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl${ApiConstants.cart}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = (data['items'] as List?) ?? [];
        
        _items.clear();
        for (final item in items) {
          final itemData = item as Map<String, dynamic>;
          final bookData = itemData['book'] as Map<String, dynamic>;
          final book = Book(
            id: bookData['id'] as String? ?? '',
            title: bookData['title'] as String? ?? '',
            author: bookData['author'] as String? ?? '',
            genre: bookData['genre'] as String? ?? '',
            description: bookData['description'] as String? ?? '',
            coverUrl: bookData['coverUrl'] as String? ?? '',
            price: (bookData['price'] as num?)?.toDouble() ?? 0.0,
            stock: (bookData['stock'] as num?)?.toInt() ?? 0,
            rating: (bookData['rating'] as num?)?.toDouble() ?? 0.0,
            reviewCount: (bookData['reviewCount'] as num?)?.toInt() ?? 0,
            isBestseller: bookData['isBestseller'] as bool? ?? false,
            isNewArrival: bookData['isNewArrival'] as bool? ?? false,
            isFeatured: bookData['isFeatured'] as bool? ?? false,
          );
          _items.add(CartItem(
            book: book,
            quantity: itemData['quantity'] as int? ?? 1,
          ));
        }
      } else if (response.statusCode == 401) {
        // Not authenticated, clear cart
        _items.clear();
      }
    } catch (e) {
      _error = 'Failed to load cart: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> add(Book book) async {
    final token = _authService.token;
    if (token == null) {
      // Not authenticated, use local storage
      _addLocal(book);
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentQuantity = quantityFor(book);
      final response = await _client.post(
        Uri.parse('$_baseUrl${ApiConstants.cartItems}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bookId': book.id,
          'quantity': currentQuantity + 1,
        }),
      );

      if (response.statusCode == 201) {
        await load();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to add to cart';
        return false;
      }
    } catch (e) {
      _error = 'Failed to add to cart: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> remove(Book book) async {
    final token = _authService.token;
    if (token == null) {
      _removeLocal(book);
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl${ApiConstants.cartItems}/${book.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        await load();
        return true;
      } else {
        _error = 'Failed to remove from cart';
        return false;
      }
    } catch (e) {
      _error = 'Failed to remove from cart: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateQuantity(Book book, int quantity) async {
    if (quantity <= 0) {
      return remove(book);
    }

    final token = _authService.token;
    if (token == null) {
      _updateQuantityLocal(book, quantity);
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.patch(
        Uri.parse('$_baseUrl${ApiConstants.cartItems}/${book.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        await load();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['error'] ?? 'Failed to update cart';
        return false;
      }
    } catch (e) {
      _error = 'Failed to update cart: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> clear() async {
    final token = _authService.token;
    if (token == null) {
      _items.clear();
      notifyListeners();
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl${ApiConstants.cart}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        _items.clear();
        return true;
      } else {
        _error = 'Failed to clear cart';
        return false;
      }
    } catch (e) {
      _error = 'Failed to clear cart: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Local methods for non-authenticated users
  void _addLocal(Book book) {
    final index = _items.indexWhere(
      (item) => item.book.id == book.id,
    );

    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(book: book));
    }

    notifyListeners();
  }

  void _removeLocal(Book book) {
    _items.removeWhere(
      (item) => item.book.id == book.id,
    );

    notifyListeners();
  }

  void _updateQuantityLocal(Book book, int quantity) {
    final index = _items.indexWhere(
      (item) => item.book.id == book.id,
    );

    if (index == -1) return;

    if (quantity > 0) {
      _items[index].quantity = quantity;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  // Legacy methods for backward compatibility
  void increaseQuantity(Book book) {
    updateQuantity(book, quantityFor(book) + 1);
  }

  void decreaseQuantity(Book book) {
    final currentQuantity = quantityFor(book);
    if (currentQuantity > 1) {
      updateQuantity(book, currentQuantity - 1);
    } else {
      remove(book);
    }
  }
}
