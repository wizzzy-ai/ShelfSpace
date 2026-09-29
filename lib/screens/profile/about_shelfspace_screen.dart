import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AboutShelfSpaceScreen extends StatelessWidget {
  const AboutShelfSpaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icons/app_icon.png',
              height: 32,
              width: 32,
              errorBuilder: (_, _, _) {
                return const Icon(
                  Icons.menu_book_rounded,
                  size: 32,
                  color: AppColors.burgundy,
                );
              },
            ),
            const SizedBox(width: 8),
            const Text('About ShelfSpace'),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          12,
          20,
          30,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                24,
                28,
                24,
                26,
              ),
              decoration: BoxDecoration(
                color: AppColors.burgundy,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      errorBuilder: (_, _, _) {
                        return const Icon(
                          Icons.auto_stories_rounded,
                          color: AppColors.burgundy,
                          size: 42,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'SHELFSPACE',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your World of Books',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            _SectionCard(
              title: 'About ShelfSpace',
              icon: Icons.menu_book_outlined,
              child: Text(
                'ShelfSpace is a modern bookstore experience designed to make discovering, saving, and ordering books simple and enjoyable. Browse books across different genres, discover new arrivals, manage your wishlist, and keep track of your orders all in one place.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: 'Our Mission',
              icon: Icons.auto_awesome_outlined,
              child: Text(
                'Our goal is to connect readers with great books through a clean, convenient, and enjoyable digital bookstore experience.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: 'What You Can Do',
              icon: Icons.apps_outlined,
              child: Column(
                children: [
                  _FeatureRow(
                    icon: Icons.search_rounded,
                    title: 'Discover Books',
                    description:
                        'Search and explore books by title, author, and genre.',
                  ),
                  const SizedBox(height: 14),
                  _FeatureRow(
                    icon: Icons.favorite_border_rounded,
                    title: 'Save Favorites',
                    description:
                        'Build your personal wishlist of books you love.',
                  ),
                  const SizedBox(height: 14),
                  _FeatureRow(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Shop Easily',
                    description:
                        'Add books to your cart and checkout with ease.',
                  ),
                  const SizedBox(height: 14),
                  _FeatureRow(
                    icon: Icons.local_shipping_outlined,
                    title: 'Track Orders',
                    description:
                        'Keep up with your orders from processing to delivery.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SectionCard(
              title: 'App Information',
              icon: Icons.info_outline_rounded,
              child: Column(
                children: [
                  _InfoRow(
                    label: 'App Name',
                    value: 'ShelfSpace',
                  ),
                  _InfoRow(
                    label: 'Tagline',
                    value: 'Your World of Books',
                  ),
                  _InfoRow(
                    label: 'Version',
                    value: '1.0.0',
                  ),
                  _InfoRow(
                    label: 'Platform',
                    value: 'Flutter',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Made for readers. Built for discovery.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.burgundy,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '© 2026 ShelfSpace. All rights reserved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.burgundy.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: AppColors.burgundy,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.burgundy,
            size: 19,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
