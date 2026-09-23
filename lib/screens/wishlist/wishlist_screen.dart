import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../services/wishlist_service.dart';
import '../../widgets/book_card.dart';
import '../books/book_details_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text('My Wishlist'),
        actions: [
          AnimatedBuilder(
            animation: WishlistService.instance,
            builder: (context, _) {
              final hasItems = WishlistService.instance.items.isNotEmpty;

              if (!hasItems) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Clear wishlist',
                onPressed: () {
                  _showClearWishlistDialog(context);
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.dark,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: WishlistService.instance,
        builder: (context, _) {
          final books = WishlistService.instance.items;

          if (books.isEmpty) {
            return _buildEmptyState(context);
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: GridView.builder(
              itemCount: books.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 18,
                childAspectRatio: 0.53,
              ),
              itemBuilder: (context, index) {
                final book = books[index];

                return BookCard(
                  book: book,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailsScreen(
                          book: book,
                          similarBooks: books
                              .where(
                                (item) => item.id != book.id,
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
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.burgundy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 44,
                color: AppColors.burgundy,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your wishlist is empty',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Save books you love and they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Browse Books'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearWishlistDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text('Clear wishlist?'),
          content: const Text(
            'This will remove all books from your wishlist.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.mutedText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                WishlistService.instance.clear();
                Navigator.pop(dialogContext);
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}