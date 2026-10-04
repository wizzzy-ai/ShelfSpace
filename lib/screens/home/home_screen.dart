import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../../widgets/book_card.dart';
import '../../widgets/category_card.dart';
import '../../widgets/featured_book_banner.dart';
import '../../widgets/notification_bell.dart';

import '../../widgets/section_header.dart';
import '../books/book_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookService _bookService = BookService();
  List<Book> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bookService.fetchBooks();
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final featured = _books.firstWhere(
      (book) => book.isFeatured,
      orElse: () => _books.first,
    );

    final bestsellers =
        _books.where((book) => book.isBestseller).toList();

    final newArrivals =
        _books.where((book) => book.isNewArrival).toList();

    const categories = [
      {
        'title': 'Fiction',
        'icon': Icons.auto_stories_outlined,
      },
      {
        'title': 'Romance',
        'icon': Icons.favorite_border_rounded,
      },
      {
        'title': 'Mystery',
        'icon': Icons.search_rounded,
      },
      {
        'title': 'Business',
        'icon': Icons.business_center_outlined,
      },
      {
        'title': 'Science',
        'icon': Icons.science_outlined,
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning 👋',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find your next great read with ShelfSpace.',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const NotificationBell(),
                  ],
                ),
              ),
            ),

            // Search
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Search ShelfSpace _books, authors, genres...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.burgundy,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Featured
            SliverToBoxAdapter(
              child: FeaturedBookBanner(
                book: featured,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailsScreen(
                        book: featured,
                        similarBooks: _books
                            .where((book) => book.id != featured.id)
                            .take(3)
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Categories
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Categories',
                  onSeeAll: () {},
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 0, 0),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 105,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) {
                      return const SizedBox(width: 10);
                    },
                    itemBuilder: (context, index) {
                      final category = categories[index];

                      return CategoryCard(
                        title: category['title'] as String,
                        icon: category['icon'] as IconData,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${category['title']} _books selected.',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bestsellers
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Bestsellers',
                  onSeeAll: () {},
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 0, 0),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 295,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: bestsellers.length,
                    separatorBuilder: (_, _) {
                      return const SizedBox(width: 14);
                    },
                    itemBuilder: (context, index) {
                      final book = bestsellers[index];

                      return BookCard(
                        book: book,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailsScreen(
                                book: book,
                                similarBooks: _books
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
                ),
              ),
            ),

            // New arrivals
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'New Arrivals',
                  onSeeAll: () {},
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 0, 30),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 295,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: newArrivals.length,
                    separatorBuilder: (_, _) {
                      return const SizedBox(width: 14);
                    },
                    itemBuilder: (context, index) {
                      final book = newArrivals[index];

                      return BookCard(
                        book: book,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailsScreen(
                                book: book,
                                similarBooks: _books
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
                ),
              ),
            ),
          ],
        ),
      ),
  );
  }
}
