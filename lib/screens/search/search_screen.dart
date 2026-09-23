import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/book.dart';
import '../../services/mock_book_service.dart';
import '../books/book_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Book> _searchResults = [];
  bool _hasSearched = false;

  String? _selectedGenre;
  double _minPrice = 0;
  double _maxPrice = 10000;
  double _minRating = 0;
  String _sortBy = 'Popularity';

  final List<String> _genres = [
    'All',
    'Fiction',
    'Romance',
    'Mystery',
    'Thriller',
    'Business',
    'Self Development',
    'Classic',
    'Lifestyle',
  ];

  final List<String> _popularSearches = [
    'Atomic Habits',
    'The Alchemist',
    'Mystery',
    'Fiction',
    'Self Development',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applySearchAndFilters();
  }

  void _applySearchAndFilters() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    var results = MockBookService.books.where((book) {
      final title = book.title.toLowerCase();
      final author = book.author.toLowerCase();
      final genre = book.genre.toLowerCase();
      final description = book.description.toLowerCase();

      final matchesSearch = title.contains(query) ||
          author.contains(query) ||
          genre.contains(query) ||
          description.contains(query);

      final matchesGenre =
          _selectedGenre == null ||
          _selectedGenre == 'All' ||
          book.genre.toLowerCase() == _selectedGenre!.toLowerCase();

      final matchesPrice =
          book.price >= _minPrice && book.price <= _maxPrice;

      final matchesRating = book.rating >= _minRating;

      return matchesSearch &&
          matchesGenre &&
          matchesPrice &&
          matchesRating;
    }).toList();

    _sortResults(results);

    setState(() {
      _searchResults = results;
      _hasSearched = true;
    });
  }

  void _sortResults(List<Book> results) {
    switch (_sortBy) {
      case 'Price: Low → High':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;

      case 'Price: High → Low':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;

      case 'Newest':
        results.sort((a, b) {
          if (a.isNewArrival && !b.isNewArrival) return -1;
          if (!a.isNewArrival && b.isNewArrival) return 1;
          return 0;
        });
        break;

      case 'Popularity':
      default:
        results.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }
  }

  void _searchPopular(String search) {
    _searchController.text = search;
    _searchFocusNode.unfocus();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
  }

  void _openBookDetails(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailsScreen(
          book: book,
          similarBooks: MockBookService.books
              .where((item) => item.id != book.id)
              .take(3)
              .toList(),
        ),
      ),
    );
  }

  int get _activeFilterCount {
    int count = 0;

    if (_selectedGenre != null && _selectedGenre != 'All') {
      count++;
    }

    if (_minPrice > 0 || _maxPrice < 10000) {
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

  void _showFilters() {
    String? tempGenre = _selectedGenre;
    double tempMinPrice = _minPrice;
    double tempMaxPrice = _maxPrice;
    double tempRating = _minRating;
    String tempSort = _sortBy;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Text(
                            'Filters & Sort',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                tempGenre = null;
                                tempMinPrice = 0;
                                tempMaxPrice = 10000;
                                tempRating = 0;
                                tempSort = 'Popularity';
                              });
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle('Genre'),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _genres.map((genre) {
                          final selected =
                              tempGenre == genre ||
                              (genre == 'All' && tempGenre == null);

                          return ChoiceChip(
                            label: Text(genre),
                            selected: selected,
                            onSelected: (_) {
                              setModalState(() {
                                tempGenre =
                                    genre == 'All' ? null : genre;
                              });
                            },
                            selectedColor: AppColors.burgundy,
                            backgroundColor: AppColors.white,
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppColors.white
                                  : AppColors.dark,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 28),

                      _sectionTitle('Price Range'),

                      const SizedBox(height: 10),

                      Text(
                        '₦${tempMinPrice.toStringAsFixed(0)} — '
                        '₦${tempMaxPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.burgundy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      RangeSlider(
                        values: RangeValues(
                          tempMinPrice,
                          tempMaxPrice,
                        ),
                        min: 0,
                        max: 10000,
                        divisions: 20,
                        activeColor: AppColors.burgundy,
                        onChanged: (values) {
                          setModalState(() {
                            tempMinPrice = values.start;
                            tempMaxPrice = values.end;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      _sectionTitle('Minimum Rating'),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        children: [0, 3, 4, 4.5].map((rating) {
                          final selected = tempRating == rating;

                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (rating > 0) ...[
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                                  rating == 0
                                      ? 'All'
                                      : '$rating+',
                                ),
                              ],
                            ),
                            selected: selected,
                            onSelected: (_) {
                              setModalState(() {
                                tempRating = rating.toDouble();
                              });
                            },
                            selectedColor: AppColors.burgundy,
                            backgroundColor: AppColors.white,
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppColors.white
                                  : AppColors.dark,
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 28),

                      _sectionTitle('Sort By'),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: tempSort,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.sort_rounded,
                            color: AppColors.burgundy,
                          ),
                        ),
                        items: const [
                          'Popularity',
                          'Price: Low → High',
                          'Price: High → Low',
                          'Newest',
                        ].map((sort) {
                          return DropdownMenuItem(
                            value: sort,
                            child: Text(sort),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              tempSort = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 28),

                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedGenre = tempGenre;
                            _minPrice = tempMinPrice;
                            _maxPrice = tempMaxPrice;
                            _minRating = tempRating;
                            _sortBy = tempSort;
                          });

                          Navigator.pop(context);

                          _applySearchAndFilters();
                        },
                        child: Text(
                          _activeFilterCount == 0
                              ? 'Apply Filters'
                              : 'Apply Filters ($_activeFilterCount)',
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text('Search Books'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _hasSearched
                  ? _buildSearchResults()
                  : _buildSearchDiscovery(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search books, authors, genres...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.burgundy,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSearchDiscovery() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find your next great read',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          Text(
            'Search by title, author, or genre.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                ),
          ),

          const SizedBox(height: 28),

          Text(
            'Popular Searches',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _popularSearches.map((search) {
              return ActionChip(
                label: Text(search),
                avatar: const Icon(
                  Icons.trending_up_rounded,
                  size: 18,
                ),
                onPressed: () => _searchPopular(search),
                backgroundColor: AppColors.white,
                side: const BorderSide(
                  color: AppColors.border,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          Text(
            'Browse by Genre',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 14),

          _buildGenreTile(
            Icons.menu_book_rounded,
            'Fiction',
          ),
          _buildGenreTile(
            Icons.favorite_border_rounded,
            'Romance',
          ),
          _buildGenreTile(
            Icons.search_rounded,
            'Mystery',
          ),
          _buildGenreTile(
            Icons.business_center_outlined,
            'Business',
          ),
          _buildGenreTile(
            Icons.psychology_outlined,
            'Self Development',
          ),
        ],
      ),
    );
  }

  Widget _buildGenreTile(
    IconData icon,
    String title,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () => _searchPopular(title),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.burgundy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.burgundy,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.mutedText,
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      children: [
        Row(
          children: [
            Text(
              '${_searchResults.length} result'
              '${_searchResults.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const Spacer(),

            Stack(
              clipBehavior: Clip.none,
              children: [
                TextButton.icon(
                  onPressed: _showFilters,
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Filter'),
                ),

                if (_activeFilterCount > 0)
                  Positioned(
                    right: 0,
                    top: 2,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: AppColors.burgundy,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_activeFilterCount',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        ..._searchResults.map(
          (book) => _buildSearchResultCard(book),
        ),
      ],
    );
  }

  Widget _buildSearchResultCard(Book book) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openBookDetails(book),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  book.coverUrl,
                  width: 78,
                  height: 108,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      width: 78,
                      height: 108,
                      color: AppColors.border,
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.mutedText,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.burgundy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        book.genre,
                        style: const TextStyle(
                          color: AppColors.burgundy,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book.rating}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '(${book.reviewCount})',
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '₦${book.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.burgundy,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                Icons.search_off_rounded,
                size: 42,
                color: AppColors.burgundy,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'No books found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'Try changing your search or filters.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedText,
                  ),
            ),

            const SizedBox(height: 20),

            OutlinedButton(
              onPressed: _clearSearch,
              child: const Text('Try Another Search'),
            ),
          ],
        ),
      ),
    );
  }
}
