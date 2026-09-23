import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/book.dart';
import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';
import '../../widgets/book_card.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;
  final List<Book> similarBooks;

  const BookDetailsScreen({
    super.key,
    required this.book,
    this.similarBooks = const [],
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: WishlistService.instance,
      builder: (context, _) {
        final isWishlisted = WishlistService.instance.contains(book);

        return Scaffold(
          backgroundColor: AppColors.cream,
          appBar: AppBar(
            backgroundColor: AppColors.cream,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.dark,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  WishlistService.instance.toggle(book);

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        duration: const Duration(milliseconds: 900),
                        content: Text(
                          isWishlisted
                              ? '${book.title} removed from wishlist'
                              : '${book.title} added to wishlist',
                        ),
                      ),
                    );
                },
                icon: Icon(
                  isWishlisted
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isWishlisted
                      ? AppColors.burgundy
                      : AppColors.dark,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        book.coverUrl,
                        width: 220,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            width: 220,
                            height: 300,
                            color: AppColors.border,
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 60,
                              color: AppColors.mutedText,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'by ${book.author}',
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${book.rating}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '(${book.reviewCount} reviews)',
                        style: const TextStyle(
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '₦${book.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.burgundy,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'In Stock',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'About this book',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    book.description,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Book Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Genre',
                    value: book.genre,
                  ),
                  _InfoRow(
                    label: 'Author',
                    value: book.author,
                  ),
                  _InfoRow(
                    label: 'Rating',
                    value: '${book.rating}/5',
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Customer Reviews',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 14),
                  const _ReviewCard(
                    name: 'James',
                    rating: 5,
                    review:
                        'A really enjoyable read. The story kept me interested from beginning to end.',
                  ),
                  const SizedBox(height: 12),
                  const _ReviewCard(
                    name: 'Sarah',
                    rating: 4,
                    review:
                        'Well written and worth reading. I would definitely recommend it.',
                  ),
                  if (similarBooks.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Text(
                      'You May Also Like',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 285,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: similarBooks.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final similarBook = similarBooks[index];

                          return BookCard(
                            book: similarBook,
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookDetailsScreen(
                                    book: similarBook,
                                    similarBooks: similarBooks
                                        .where(
                                          (item) =>
                                              item.id != similarBook.id,
                                        )
                                        .take(3)
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            WishlistService.instance.toggle(book);

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  duration:
                                      const Duration(milliseconds: 900),
                                  content: Text(
                                    isWishlisted
                                        ? 'Removed from wishlist'
                                        : 'Added to wishlist',
                                  ),
                                ),
                              );
                          },
                          icon: Icon(
                            isWishlisted
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                          ),
                          label: Text(
                            isWishlisted ? 'Saved' : 'Wishlist',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.burgundy,
                            side: const BorderSide(
                              color: AppColors.burgundy,
                            ),
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            CartService.instance.add(book);

                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  duration: const Duration(milliseconds: 1000),
                                  content: Text(
                                    '${book.title} added to cart',
                                  ),
                                ),
                              );
                          },
                          icon: const Icon(
                            Icons.shopping_cart_outlined,
                          ),
                          label: const Text('Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.mutedText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final int rating;
  final String review;

  const _ReviewCard({
    required this.name,
    required this.rating,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    AppColors.burgundy.withValues(alpha: 0.10),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: index < rating
                        ? Colors.amber
                        : AppColors.border,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review,
            style: const TextStyle(
              color: AppColors.mutedText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}