import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/book.dart';

class FeaturedBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const FeaturedBookCard({
    super.key,
    required this.book,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final bool compact = width < 360;
          final bool small = width < 440;

          if (compact) {
            return _buildCompactCard(context, width);
          }

          return _buildStandardCard(context, width, small);
        },
      ),
    );
  }

  Widget _buildStandardCard(
    BuildContext context,
    double width,
    bool small,
  ) {
    final imageWidth = small ? 88.0 : 105.0;
    final imageHeight = small ? 124.0 : 145.0;
    final cardHeight = small ? 178.0 : 195.0;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          height: cardHeight,
          decoration: BoxDecoration(
            color: AppColors.burgundy,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.burgundy.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(
                  right: -35,
                  top: -35,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: -30,
                  bottom: -70,
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.04),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(small ? 14 : 17),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _buildTextContent(
                          context,
                          small: small,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          book.coverUrl,
                          width: imageWidth,
                          height: imageHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return Container(
                              width: imageWidth,
                              height: imageHeight,
                              color: Theme.of(context).colorScheme.outlineVariant,
                              child: Icon(
                                Icons.menu_book_rounded,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(
    BuildContext context,
    double width,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          height: 190,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.burgundy,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.burgundy.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTextContent(
                  context,
                  small: true,
                ),
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  book.coverUrl,
                  width: 76,
                  height: 112,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return Container(
                      width: 76,
                      height: 112,
                      color: Theme.of(context).colorScheme.outlineVariant,
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 28,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(
    BuildContext context, {
    required bool small,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'FEATURED BOOK',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 7,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.7,
            ),
          ),
        ),

        const SizedBox(height: 7),

        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.white,
            fontSize: small ? 16 : 19,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          'by ${book.author}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 10,
          ),
        ),

        const SizedBox(height: 7),

        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              color: Colors.amber,
              size: 14,
            ),
            const SizedBox(width: 3),
            Text(
              '${book.rating}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                '₦${book.price.toStringAsFixed(0)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        SizedBox(
          height: 28,
          child: TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: AppColors.burgundy,
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size.zero,
              tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Explore Book',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}