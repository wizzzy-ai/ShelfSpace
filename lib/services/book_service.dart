import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  BookService({http.Client? client}) : _client = client ?? http.Client();

  static const String _googleBooksBaseUrl =
      'https://www.googleapis.com/books/v1/volumes';
  final http.Client _client;

  /// Fetch books from Google Books API
  /// [query] - Search query (default: 'fiction')
  /// [limit] - Number of results (1-40, default: 20)
  Future<List<Book>> fetchBooks({
    String query = 'subject:fiction',
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse(_googleBooksBaseUrl).replace(
        queryParameters: {
          'q': query.isEmpty ? 'subject:fiction' : query,
          'maxResults': limit.clamp(1, 40).toString(),
          'orderBy': 'relevance',
          'printType': 'books',
        },
      );

      final response = await _client.get(uri, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode != 200) {
        throw BookServiceException(
          'Failed to fetch books: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = (data['items'] as List?) ?? [];

      return items
          .map((item) => _parseGoogleBook(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw BookServiceException('Error fetching books: $e');
    }
  }

  /// Fetch book details by ID
  Future<Book> fetchBookDetails(String id) async {
    try {
      final uri = Uri.parse('$_googleBooksBaseUrl/${Uri.encodeComponent(id)}');
      final response = await _client.get(uri, headers: {
        'Accept': 'application/json',
      });

      if (response.statusCode != 200) {
        throw BookServiceException(
          'Failed to fetch book details: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseGoogleBook(data);
    } catch (e) {
      throw BookServiceException('Error fetching book details: $e');
    }
  }

  /// Search books by query
  Future<List<Book>> searchBooks(String query, {int limit = 20}) {
    return fetchBooks(query: query, limit: limit);
  }

  /// Fetch books by category/genre
  Future<List<Book>> fetchBooksByCategory(String category, {int limit = 20}) {
    return fetchBooks(
      query: 'subject:${category.trim()}',
      limit: limit,
    );
  }

  /// Fetch bestseller books
  Future<List<Book>> fetchBestsellers({int limit = 10}) {
    return fetchBooks(query: 'bestseller', limit: limit);
  }

  /// Fetch new arrivals
  Future<List<Book>> fetchNewArrivals({int limit = 10}) {
    return fetchBooks(query: 'new releases', limit: limit);
  }

  /// Fetch featured books
  Future<List<Book>> fetchFeaturedBooks({int limit = 10}) {
    return fetchBooks(query: 'featured', limit: limit);
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

  /// Parse Google Books API response
  Book _parseGoogleBook(Map<String, dynamic> json) {
    final volumeInfo = _safeMap(json['volumeInfo']);
    final saleInfo = _safeMap(json['saleInfo']);
    final imageLinks = _safeMap(volumeInfo['imageLinks']);

    // Extract authors
    final authorsList = (volumeInfo['authors'] as List?) ?? [];
    final authors = authorsList.map((a) => a.toString()).toList();
    final author = authors.isEmpty ? 'Unknown Author' : authors.first;

    // Extract genres/categories
    final categories = (volumeInfo['categories'] as List?) ?? [];
    final genre = categories.isEmpty
        ? 'Fiction'
        : (categories.first as String? ?? 'Fiction');

    // Extract price
    final listPrice = _safeMap(saleInfo['listPrice']);
    final price = (listPrice['amount'] as num?)?.toDouble() ?? 0.0;

    // Extract image URL
    final thumbnailUrl =
        (imageLinks['thumbnail'] as String?) ?? imageLinks['smallThumbnail'];
    final imageUrl = (thumbnailUrl as String?)
            ?.replaceFirst('http://', 'https://') ??
        'https://via.placeholder.com/150';

    return Book(
      id: json['id'] as String? ?? '',
      title: volumeInfo['title'] as String? ?? 'Untitled',
      author: author,
      genre: genre,
      description: _stripHtml(
        volumeInfo['description'] as String? ?? 'No description available.',
      ),
      coverUrl: imageUrl,
      price: price,
      rating: (volumeInfo['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (volumeInfo['ratingsCount'] as num?)?.toInt() ?? 0,
      isBestseller: false,
      isNewArrival: false,
      isFeatured: false,
    );
  }

  /// Safely cast to Map
  static Map<String, dynamic> _safeMap(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  /// Strip HTML tags from text
  static String _stripHtml(String value) {
    return value.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}

class BookServiceException implements Exception {
  final String message;
  final int? statusCode;

  BookServiceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
