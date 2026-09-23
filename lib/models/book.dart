class Book {
  final String id;
  final String title;
  final String author;
  final String genre;
  final String description;
  final String coverUrl;
  final double price;
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
    required this.rating,
    required this.reviewCount,
    this.isBestseller = false,
    this.isNewArrival = false,
    this.isFeatured = false,
  });
}