import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../../widgets/app_state_view.dart';
import '../../widgets/book_card.dart';
import '../books/book_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BookService _bookService = BookService();

  final List<String> _recentSearches = [
    'Atomic Habits',
    'The Silent Patient',
  ];

  final List<String> _popularSearches = [
    'Fiction',
    'Romance',
    'Mystery',
    'Business',
    'Self Development',
  ];

  String _selectedGenre = 'All';
  double _maxPrice = 10000;
  double _minRating = 0;
  String _sortBy = 'Popularity';
  List<Book> _allBooks = [];
  bool _isLoading = false;

  bool get _hasSearch =>
      _searchController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final books = await _bookService.fetchBooks();
      if (!mounted) return;
      setState(() {
        _allBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Book> get _filteredBooks {
    final query = _searchController.text.trim().toLowerCase();

    List<Book> results = _allBooks.where((book) {
      final matchesSearch = query.isEmpty ||
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.genre.toLowerCase().contains(query) ||
          book.description.toLowerCase().contains(query);

      final matchesGenre = _selectedGenre == 'All' ||
          book.genre.toLowerCase() ==
              _selectedGenre.toLowerCase();

      final matchesPrice = book.price <= _maxPrice;

      final matchesRating = book.rating >= _minRating;

      return matchesSearch &&
          matchesGenre &&
          matchesPrice &&
          matchesRating;
    }).toList();

    switch (_sortBy) {
      case 'Price: Low → High':
        results.sort(
          (a, b) => a.price.compareTo(b.price),
        );
        break;

      case 'Price: High → Low':
        results.sort(
          (a, b) => b.price.compareTo(a.price),
        );
        break;

      case 'Newest':
        results.sort(
          (a, b) {
            if (a.isNewArrival == b.isNewArrival) {
              return 0;
            }

            return a.isNewArrival ? -1 : 1;
          },
        );
        break;

      case 'Popularity':
      default:
        results.sort(
          (a, b) => b.reviewCount.compareTo(a.reviewCount),
        );
        break;
    }

    return results;
  }

  int get _activeFilterCount {
    int count = 0;

    if (_selectedGenre != 'All') {
      count++;
    }

    if (_maxPrice < 10000) {
      count++;
    }

    if (_minRating > 0) {
      count++;
    }

    if (_sortBy != 'Popularity') {
      count++;
    }

    return count;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String value) {
    final query = value.trim();

    if (query.isEmpty) {
      return;
    }

    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);

        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }

    FocusScope.of(context).unfocus();
  }

  void _useSearch(String value) {
    _searchController.text = value;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: _searchController.text.length,
      ),
    );

    _performSearch(value);
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  void _showFilters() {
    String tempGenre = _selectedGenre;
    double tempMaxPrice = _maxPrice;
    double tempMinRating = _minRating;
    String tempSortBy = _sortBy;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 45,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Filters & Sort',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                tempGenre = 'All';
                                tempMaxPrice = 10000;
                                tempMinRating = 0;
                                tempSortBy = 'Popularity';
                              });
                            },
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                color:
                                    AppColors.burgundy,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Genre',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'All',
                          'Fiction',
                          'Romance',
                          'Thriller',
                          'Mystery',
                          'Classic',
                          'Self Development',
                          'Lifestyle',
                        ].map((genre) {
                          final selected =
                              tempGenre == genre;

                          return ChoiceChip(
                            label: Text(genre),
                            selected: selected,
                            onSelected: (_) {
                              setSheetState(() {
                                tempGenre = genre;
                              });
                            },
                            selectedColor:
                                AppColors.burgundy
                                    .withValues(
                              alpha: 0.10,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? AppColors.burgundy
                                  : Theme.of(context).colorScheme.outlineVariant,
                            ),
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppColors.burgundy
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Maximum Price',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₦${tempMaxPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.burgundy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: tempMaxPrice,
                        min: 0,
                        max: 10000,
                        divisions: 20,
                        activeColor:
                            AppColors.burgundy,
                        inactiveColor:
                            Theme.of(context).colorScheme.outlineVariant,
                        onChanged: (value) {
                          setSheetState(() {
                            tempMaxPrice = value;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Minimum Rating',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: [0.0, 3.0, 4.0, 4.5]
                            .map((rating) {
                          final selected =
                              tempMinRating == rating;

                          return ChoiceChip(
                            label: Text(
                              rating == 0
                                  ? 'Any'
                                  : '${rating.toStringAsFixed(1)}+',
                            ),
                            selected: selected,
                            onSelected: (_) {
                              setSheetState(() {
                                tempMinRating = rating;
                              });
                            },
                            selectedColor:
                                AppColors.burgundy
                                    .withValues(
                              alpha: 0.10,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? AppColors.burgundy
                                  : Theme.of(context).colorScheme.outlineVariant,
                            ),
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppColors.burgundy
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Sort By',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: tempSortBy,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.sort_rounded,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Popularity',
                            child: Text('Popularity'),
                          ),
                          DropdownMenuItem(
                            value: 'Price: Low → High',
                            child:
                                Text('Price: Low → High'),
                          ),
                          DropdownMenuItem(
                            value: 'Price: High → Low',
                            child:
                                Text('Price: High → Low'),
                          ),
                          DropdownMenuItem(
                            value: 'Newest',
                            child: Text('Newest'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setSheetState(() {
                            tempSortBy = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedGenre = tempGenre;
                              _maxPrice = tempMaxPrice;
                              _minRating = tempMinRating;
                              _sortBy = tempSortBy;
                            });

                            Navigator.pop(sheetContext);
                          },
                          child: const Text(
                            'Apply Filters',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openBook(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailsScreen(
          book: book,
          similarBooks: _allBooks
              .where(
                (item) => item.id != book.id,
              )
              .take(3)
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = _filteredBooks;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
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
            const Text('Search'),
          ],
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: _buildSearchField(),
              ),
            ),
            if (!_hasSearch) ...[
              SliverToBoxAdapter(
                child: _buildQuickSearchSection(
                  title: 'Recent Searches',
                  items: _recentSearches,
                  icon: Icons.history_rounded,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildQuickSearchSection(
                  title: 'Popular Searches',
                  items: _popularSearches,
                  icon: Icons.trending_up_rounded,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildBrowseGenres(),
              ),
            ],
            if (_hasSearch) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  12,
                ),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${books.length} ${books.length == 1 ? 'book' : 'books'} found',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (_activeFilterCount > 0)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.burgundy,
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_activeFilterCount',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: _showFilters,
                        tooltip: 'Filters',
                        icon: const Icon(
                          Icons.tune_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading && books.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (books.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyView(
                    icon: Icons.search_off_rounded,
                    title: 'No books found',
                    message:
                        'Try a different title, author, genre, or adjust your filters.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    30,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final book = books[index];

                        return BookCard(
                          book: book,
                          fillWidth: true,
                          onTap: () {
                            _openBook(book);
                          },
                        );
                      },
                      childCount: books.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 18,
                      mainAxisExtent: 340,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.dark.withValues(
              alpha: 0.04,
            ),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: _performSearch,
        decoration: InputDecoration(
          hintText: 'Search ShelfSpace books, authors, genres...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          suffixIcon: _hasSearch
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildQuickSearchSection({
    required String title,
    required List<String> items,
    required IconData icon,
  }) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        26,
        20,
        0,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items.map((item) {
              return ActionChip(
                onPressed: () {
                  _useSearch(item);
                },
                avatar: Icon(
                  icon,
                  size: 16,
                  color: AppColors.burgundy,
                ),
                label: Text(item),
                backgroundColor: Theme.of(context).colorScheme.surface,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                labelStyle: const TextStyle(
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseGenres() {
    const genres = [
      ('Fiction', Icons.auto_stories_outlined),
      ('Romance', Icons.favorite_border_rounded),
      ('Mystery', Icons.search_rounded),
      ('Business', Icons.business_center_outlined),
      ('Classic', Icons.menu_book_outlined),
      ('Lifestyle', Icons.self_improvement_outlined),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        28,
        20,
        30,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Browse by Genre',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...genres.map(
            (genre) => Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {
                    _useSearch(genre.$1);
                  },
                  borderRadius:
                      BorderRadius.circular(14),
                  child: Container(
                    padding:
                        const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.burgundy
                                .withValues(
                              alpha: 0.08,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              11,
                            ),
                          ),
                          child: Icon(
                            genre.$2,
                            color: AppColors.burgundy,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            genre.$1,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
