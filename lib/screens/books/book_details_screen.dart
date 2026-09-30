import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/book.dart';
import '../../services/cart_service.dart';
import '../../services/mock_book_service.dart';
import '../../services/wishlist_service.dart';
import '../../widgets/book_card.dart';
import '../cart/cart_screen.dart';
import 'reviews_screen.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;
  final List<Book>? similarBooks;

  const BookDetailsScreen({
    super.key,
    required this.book,
    this.similarBooks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        title: const Text(
          'Book Details',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          SizedBox(
            width: 48,
            height: 48,
            child: AnimatedBuilder(
              animation: WishlistService.instance,
              builder: (context, _) {
                final isWishlisted =
                    WishlistService.instance.contains(book);

                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  splashRadius: 22,
                  tooltip: isWishlisted
                      ? 'Remove from wishlist'
                      : 'Add to wishlist',
                  onPressed: () {
                    WishlistService.instance.toggle(book);

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          duration: const Duration(milliseconds: 900),
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
                    size: 22,
                    color: isWishlisted
                        ? AppColors.burgundy
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final bool isDesktop = width >= 1000;
          final bool isTablet = width >= 700 && width < 1000;

          final double maxContentWidth = isDesktop
              ? 1120
              : isTablet
                  ? 900
                  : double.infinity;

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxContentWidth,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    isDesktop ? 32 : 20,
                    20,
                    isDesktop ? 32 : 20,
                    40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroSection(
                        context,
                        isDesktop: isDesktop,
                        isTablet: isTablet,
                      ),
                      const SizedBox(height: 32),
                      _buildAboutSection(context),
                      const SizedBox(height: 28),
                      _buildBookInformation(context),
                      const SizedBox(height: 28),
                      _buildReviewsPreview(context),
                      const SizedBox(height: 32),
                      _buildSimilarBooks(context),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context, {
    required bool isDesktop,
    required bool isTablet,
  }) {
    if (isDesktop || isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: _buildCover(
                context,
                width: isDesktop ? 300 : 260,
                height: isDesktop ? 410 : 355,
              ),
            ),
          ),
          const SizedBox(width: 36),
          Expanded(
            flex: 6,
            child: _buildBookInfo(context),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: _buildCover(
            context,
            width: 215,
            height: 300,
          ),
        ),
        const SizedBox(height: 24),
        _buildBookInfo(context),
      ],
    );
  }

  Widget _buildCover(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    return Stack(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.dark.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              book.coverUrl,
              width: width,
              height: height,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Container(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 70,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ),
        if (book.isBestseller)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.burgundy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Bestseller',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBookInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.genre.toUpperCase(),
          style: const TextStyle(
            color: AppColors.burgundy,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          book.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'by ${book.author}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 22,
            ),
            const SizedBox(width: 5),
            Text(
              book.rating.toString(),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${book.reviewCount} reviews',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '₦${book.price.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.burgundy,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 18,
            ),
            SizedBox(width: 6),
            Text(
              'In stock',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAddToCartButton(context),
              const SizedBox(height: 10),
              _buildBuyNowButton(context),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildAddToCartButton(context),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildBuyNowButton(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          CartService.instance.add(book);

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: const Duration(milliseconds: 1000),
                content: Text('${book.title} added to cart'),
              ),
            );
        },
        icon: const Icon(
          Icons.shopping_cart_outlined,
          size: 20,
        ),
        label: const Text(
          'Add to Cart',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.burgundy,
          side: const BorderSide(
            color: AppColors.burgundy,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildBuyNowButton(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          CartService.instance.add(book);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CartScreen(),
            ),
          );
        },
        icon: const Icon(
          Icons.flash_on_rounded,
          size: 19,
        ),
        label: const Text(
          'Buy Now',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSectionCard(
      context: context,
      title: 'About this book',
      child: Text(
        book.description,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _buildBookInformation(BuildContext context) {
    return _buildSectionCard(
      context: context,
      title: 'Book Information',
      child: Column(
        children: [
          _infoRow(context, 'Title', book.title),
          _infoDivider(context),
          _infoRow(context, 'Author', book.author),
          _infoDivider(context),
          _infoRow(context, 'Genre', book.genre),
          _infoDivider(context),
          _infoRow(
            context,
            'Rating',
            '${book.rating} / 5',
          ),
          _infoDivider(context),
          _infoRow(
            context,
            'Reviews',
            '${book.reviewCount}',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsPreview(BuildContext context) {
    return _buildSectionCard(
      context: context,
      title: 'Customer Reviews',
      action: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewsScreen(book: book),
            ),
          );
        },
        child: const Text(
          'See all',
          style: TextStyle(
            color: AppColors.burgundy,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                book.rating.toString(),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_rounded,
                        color: index < book.rating.round()
                            ? Colors.amber
                            : Theme.of(context).colorScheme.outlineVariant,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${book.reviewCount} customer reviews',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          _reviewPreview(
            context: context,
            name: 'Daniel',
            date: '2 days ago',
            text:
                'Really enjoyed this book. The writing is excellent and the story kept me interested.',
            rating: 5,
          ),
          const SizedBox(height: 14),
          _reviewPreview(
            context: context,
            name: 'Hannah',
            date: '1 week ago',
            text:
                'A great read from beginning to end. Definitely worth adding to your collection.',
            rating: 4,
          ),
        ],
      ),
    );
  }

  Widget _reviewPreview({
    required BuildContext context,
    required String name,
    required String date,
    required String text,
    required int rating,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.burgundy,
                ),
                alignment: Alignment.center,
                child: Text(
                  name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: index < rating
                        ? Colors.amber
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarBooks(BuildContext context) {
    final books = (similarBooks ??
            MockBookService.books)
        .where((item) => item.id != book.id)
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: Text(
            'You May Also Like',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final similarBook = books[index];

              return BookCard(
                book: similarBook,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailsScreen(
                        book: similarBook,
                        similarBooks: books,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}
