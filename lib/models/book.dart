class Book {
  final String id;
  final String title;
  final String author;
  final String genre;
  final String description;
  final String coverUrl;
  final double price;
  final int stock;
  final double rating;
  final int reviewCount;
  final bool isBestseller;
  final bool isNewArrival;
  final bool isFeatured;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.description,
    required this.coverUrl,
    required this.price,
    this.stock = 0,
    required this.rating,
    required this.reviewCount,
    this.isBestseller = false,
    this.isNewArrival = false,
    this.isFeatured = false,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? genre,
    String? description,
    String? coverUrl,
    double? price,
    int? stock,
    double? rating,
    int? reviewCount,
    bool? isBestseller,
    bool? isNewArrival,
    bool? isFeatured,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isBestseller: isBestseller ?? this.isBestseller,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}