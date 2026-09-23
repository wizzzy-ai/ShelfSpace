import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/book.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        WishlistService.instance,
        CartService.instance,
      ]),
      builder: (context, _) {
        final isWishlisted = WishlistService.instance.contains(book);
        final cartQuantity = CartService.instance.quantityFor(book);

        return SizedBox(
          width: 150,
          height: 285,
          child: GestureDetector(
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
                        width: 150,
                        height: 190,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            width: 150,
                            height: 190,
                            color: AppColors.border,
                            child: const Icon(
                              Icons.menu_book_rounded,
                              size: 40,
                              color: AppColors.mutedText,
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
                        color: AppColors.white,
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
                                  : AppColors.dark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
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
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₦${book.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.burgundy,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
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
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 16,
                                color: cartQuantity > 0
                                    ? AppColors.white
                                    : AppColors.burgundy,
                              ),
                              if (cartQuantity > 0)
                                Positioned(
                                  right: 1,
                                  top: 1,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                      vertical: 1,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: AppColors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      cartQuantity > 9
                                          ? '9+'
                                          : '$cartQuantity',
                                      style: const TextStyle(
                                        color: AppColors.burgundy,
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}