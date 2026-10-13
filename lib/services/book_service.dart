import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../core/constants/api_constants.dart';
import 'auth_service.dart';

class BookService {
  BookService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final String _baseUrl = ApiConstants.baseUrl;
  final AuthService _authService = AuthService();

  /// Fetch books from backend API
  /// [query] - Search query (optional)
  /// [genre] - Filter by genre (optional)
  /// [featured] - Filter by featured (optional)
  /// [bestseller] - Filter by bestseller (optional)
  /// [newArrival] - Filter by new arrival (optional)
  /// [sort] - Sort order (newest, price_asc, price_desc, rating, title)
  /// [page] - Page number (default: 1)
  /// [limit] - Number of results per page (default: 24)
  Future<List<Book>> fetchBooks({
    String? query,
    String? genre,
    bool? featured,
    bool? bestseller,
    bool? newArrival,
    String sort = 'newest',
    int page = 1,
    int limit = 24,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiConstants.books}').replace(
        queryParameters: {
          if (query != null && query.isNotEmpty) 'q': query,
          if (genre != null && genre.isNotEmpty) 'genre': genre,
          if (featured != null) 'featured': featured.toString(),
          if (bestseller != null) 'bestseller': bestseller.toString(),
          if (newArrival != null) 'newArrival': newArrival.toString(),
          'sort': sort,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw BookServiceException(
          'Failed to fetch books: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (data['items'] as List?) ?? [];

      return items
          .map((item) => _parseBackendBook(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw BookServiceException('Error fetching books: $e');
    }
  }

  Future<void> uploadEbook({
    required String bookId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final token = _authService.token;
    if (token == null) {
      throw BookServiceException('Sign in as an admin to upload ebooks');
    }

    final request =
        http.Request(
            'PUT',
            Uri.parse('$_baseUrl${ApiConstants.adminBooks}/$bookId/ebook'),
          )
          ..headers.addAll({
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/octet-stream',
            'X-Ebook-Filename': Uri.encodeComponent(fileName),
          })
          ..bodyBytes = bytes;

    final response = await http.Response.fromStream(
      await _client.send(request),
    );
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw BookServiceException(
        data['error'] as String? ?? 'Failed to upload ebook',
        statusCode: response.statusCode,
      );
    }
  }

  /// Fetch book details by ID
  Future<Book> fetchBookDetails(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiConstants.books}/$id');
      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw BookServiceException(
          'Failed to fetch book details: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseBackendBook(data['book'] as Map<String, dynamic>);
    } catch (e) {
      throw BookServiceException('Error fetching book details: $e');
    }
  }

  /// Fetch book reviews by ID
  Future<List<Map<String, dynamic>>> fetchBookReviews(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl${ApiConstants.bookReviews}/$id/reviews');
      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw BookServiceException(
          'Failed to fetch book reviews: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (data['items'] as List?) ?? [];
      return items.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      throw BookServiceException('Error fetching book reviews: $e');
    }
  }

  /// Search books by query
  Future<List<Book>> searchBooks(String query, {int limit = 24}) {
    return fetchBooks(query: query, limit: limit);
  }

  /// Fetch books by category/genre
  Future<List<Book>> fetchBooksByCategory(String category, {int limit = 24}) {
    return fetchBooks(genre: category, limit: limit);
  }

  /// Fetch bestseller books
  Future<List<Book>> fetchBestsellers({int limit = 10}) {
    return fetchBooks(bestseller: true, limit: limit);
  }

  /// Fetch new arrivals
  Future<List<Book>> fetchNewArrivals({int limit = 10}) {
    return fetchBooks(newArrival: true, limit: limit);
  }

  /// Fetch featured books
  Future<List<Book>> fetchFeaturedBooks({int limit = 10}) {
    return fetchBooks(featured: true, limit: limit);
  }

  /// Get popular categories
  Future<List<String>> fetchCategories() async {
    return const [
      'Fiction',
      'Non-Fiction',
      'Science Fiction',
      'Fantasy',
      'Mystery',
      'Romance',
      'Biography',
      'History',
      'Self-Help',
      'Business',
      'Technology',
      'Science',
      'Art',
      'Children',
    ];
  }

  /// Parse backend API response
  Book _parseBackendBook(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      author: json['author'] as String? ?? 'Unknown Author',
      genre: json['genre'] as String? ?? 'Fiction',
      description:
          json['description'] as String? ?? 'No description available.',
      coverUrl:
          json['coverUrl'] as String? ?? 'https://via.placeholder.com/150',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      isBestseller: json['isBestseller'] as bool? ?? false,
      isNewArrival: json['isNewArrival'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      hasEbook: json['hasEbook'] as bool? ?? false,
      ebookFormat: json['ebookFormat'] as String?,
    );
  }
}

class BookServiceException implements Exception {
  final String message;
  final int? statusCode;

  BookServiceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
