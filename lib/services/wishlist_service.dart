import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/book.dart';
import 'auth_service.dart';

class WishlistService extends ChangeNotifier {
  WishlistService._();

  static final WishlistService instance = WishlistService._();

  final List<Book> _items = [];
  final AuthService _authService = AuthService();
  final http.Client _client = http.Client();
  final String _baseUrl = ApiConstants.baseUrl;

  bool _isLoading = false;
  String? _error;

  List<Book> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool contains(Book book) {
    return _items.any(
      (item) => item.id == book.id,
    );
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
        Uri.parse('$_baseUrl${ApiConstants.wishlist}'),
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
          final bookData = item as Map<String, dynamic>;
          _items.add(Book(
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
          ));
        }
      } else if (response.statusCode == 401) {
        // Not authenticated, clear wishlist
        _items.clear();
      }
    } catch (e) {
      _error = 'Failed to load wishlist: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggle(Book book) async {
    final token = _authService.token;
    if (token == null) {
      _toggleLocal(book);
      return true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (contains(book)) {
        // Remove from wishlist
        final response = await _client.delete(
          Uri.parse('$_baseUrl${ApiConstants.wishlist}/${book.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 204) {
          await load();
          return true;
        } else {
          _error = 'Failed to remove from wishlist';
          return false;
        }
      } else {
        // Add to wishlist
        final response = await _client.post(
          Uri.parse('$_baseUrl${ApiConstants.wishlist}/${book.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 201) {
          await load();
          return true;
        } else {
          final data = jsonDecode(response.body);
          _error = data['error'] ?? 'Failed to add to wishlist';
          return false;
        }
      }
    } catch (e) {
      _error = 'Failed to update wishlist: $e';
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
        Uri.parse('$_baseUrl${ApiConstants.wishlist}/${book.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        await load();
        return true;
      } else {
        _error = 'Failed to remove from wishlist';
        return false;
      }
    } catch (e) {
      _error = 'Failed to remove from wishlist: $e';
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
      // Remove all items one by one (backend doesn't have clear endpoint)
      for (final book in List.from(_items)) {
        await remove(book);
      }
      return true;
    } catch (e) {
      _error = 'Failed to clear wishlist: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Local methods for non-authenticated users
  void _toggleLocal(Book book) {
    if (contains(book)) {
      _removeLocal(book);
    } else {
      _items.add(book);
    }
    notifyListeners();
  }

  void _removeLocal(Book book) {
    _items.removeWhere(
      (item) => item.id == book.id,
    );
    notifyListeners();
  }
}
