import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/book.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final bool fillWidth;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.fillWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        WishlistService.instance,
        CartService.instance,
      ]),
      builder: (context, _) {
        final isWishlisted =
            WishlistService.instance.contains(book);

        final cartQuantity =
            CartService.instance.quantityFor(book);

        return LayoutBuilder(
          builder: (context, constraints) {
            // Normal horizontal cards.
            if (!fillWidth) {
              return SizedBox(
                width: 150,
                height: 285,
                child: _buildCard(
                  context,
                  width: 150,
                  coverHeight: 190,
                  isWishlisted: isWishlisted,
                  cartQuantity: cartQuantity,
                ),
              );
            }

            // Responsive grid cards.
            //
            // The grid gives this widget a fixed height
            // (currently around 340px). We MUST respect it.
            final availableHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 340.0;

            // Leave enough room underneath the cover for:
            // title + author + rating + price + cart button.
            final coverHeight = (availableHeight - 88).clamp(
              180.0,
              availableHeight,
            );

            return SizedBox(
              width: double.infinity,
              height: availableHeight,
              child: _buildCard(
                context,
                width: constraints.maxWidth,
                coverHeight: coverHeight,
                isWishlisted: isWishlisted,
                cartQuantity: cartQuantity,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required double width,
    required double coverHeight,
    required bool isWishlisted,
    required int cartQuantity,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  book.coverUrl,
                  width: width,
                  height: coverHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return Container(
                      width: width,
                      height: coverHeight,
                      color: Theme.of(context).colorScheme.outlineVariant,
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 40,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),

              if (book.isBestseller)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.burgundy,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Bestseller',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      WishlistService.instance.toggle(book);

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            duration:
                                const Duration(milliseconds: 900),
                            content: Text(
                              isWishlisted
                                  ? '${book.title} removed from wishlist'
                                  : '${book.title} added to wishlist',
                            ),
                          ),
                        );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Icon(
                        isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 20,
                        color: isWishlisted
                            ? AppColors.burgundy
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 15,
                color: Colors.amber,
              ),
              const SizedBox(width: 3),
              Text(
                '${book.rating}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              Flexible(
                child: Text(
                  '₦${book.price.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.burgundy,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 5),

              Material(
                color: cartQuantity > 0
                    ? AppColors.burgundy
                    : AppColors.cream,
                borderRadius: BorderRadius.circular(7),
                child: InkWell(
                  borderRadius: BorderRadius.circular(7),
                  onTap: () {
                    CartService.instance.add(book);

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          duration:
                              const Duration(milliseconds: 900),
                          content: Text(
                            '${book.title} added to cart',
                          ),
                        ),
                      );
                  },
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 16,
                      color: cartQuantity > 0
                          ? AppColors.white
                          : AppColors.burgundy,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
