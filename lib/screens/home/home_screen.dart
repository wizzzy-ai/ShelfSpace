import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../services/mock_book_service.dart';
import '../../widgets/book_card.dart';
import '../../widgets/category_card.dart';
import '../../widgets/section_header.dart';
import '../books/book_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final books = MockBookService.books;

    final featured = books.firstWhere(
      (book) => book.isFeatured,
      orElse: () => books.first,
    );

    final bestsellers =
        books.where((book) => book.isBestseller).toList();

    final newArrivals =
        books.where((book) => book.isNewArrival).toList();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning 👋',
                            style: GoogleFonts.inter(
                              color: AppColors.mutedText,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Find your next\ngreat read.',
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.dark,
                              fontSize: 28,
                              height: 1.1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.dark,
                              size: 23,
                            ),
                          ),
                          Positioned(
                            top: 9,
                            right: 10,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.burgundy,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    hintText: 'Search books, authors, genres...',
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 195,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.burgundy,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              'FEATURED BOOK',
                              style: GoogleFonts.inter(
                                color: AppColors.cream
                                    .withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Text(
                              featured.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.playfairDisplay(
                                color: AppColors.cream,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              featured.author,
                              style: GoogleFonts.inter(
                                color: AppColors.cream
                                    .withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookDetailsScreen(
                                      book: featured,
                                      similarBooks: books
                                          .where((book) => book.id != featured.id)
                                          .take(3)
                                          .toList(),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 13,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cream,
                                  borderRadius:
                                      BorderRadius.circular(9),
                                ),
                                child: Text(
                                  'View book',
                                  style: GoogleFonts.inter(
                                    color: AppColors.burgundy,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.network(
                          featured.coverUrl,
                          width: 105,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              width: 105,
                              height: 150,
                              color: AppColors.border,
                              child: const Icon(
                                Icons.book_rounded,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
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
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      CategoryCard(
                        title: 'Fiction',
                        icon: Icons.auto_stories_rounded,
                      ),
                      SizedBox(width: 10),
                      CategoryCard(
                        title: 'Romance',
                        icon: Icons.favorite_border_rounded,
                      ),
                      SizedBox(width: 10),
                      CategoryCard(
                        title: 'Mystery',
                        icon: Icons.search_rounded,
                      ),
                      SizedBox(width: 10),
                      CategoryCard(
                        title: 'Business',
                        icon: Icons.business_center_outlined,
                      ),
                      SizedBox(width: 10),
                      CategoryCard(
                        title: 'Science',
                        icon: Icons.science_outlined,
                      ),
                    ],
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
                  height: 285,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: bestsellers.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return BookCard(
                        book: bestsellers[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailsScreen(
                                book: bestsellers[index],
                                similarBooks: books
                                    .where((book) => book.id != bestsellers[index].id)
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
                  height: 285,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: newArrivals.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return BookCard(
                        book: newArrivals[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailsScreen(
                                book: newArrivals[index],
                                similarBooks: books
                                    .where((book) => book.id != newArrivals[index].id)
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