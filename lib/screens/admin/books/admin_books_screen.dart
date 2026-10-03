import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/book.dart';
import '../../../services/mock_book_service.dart';

class AdminBooksScreen extends StatefulWidget {
  const AdminBooksScreen({super.key});

  @override
  State<AdminBooksScreen> createState() => _AdminBooksScreenState();
}

class _AdminBooksScreenState extends State<AdminBooksScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedGenre = 'All genres';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editBook(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add book'),
      ),
      body: AnimatedBuilder(
        animation: MockBookService.instance,
        builder: (context, _) {
          final allBooks = MockBookService.books;

          final genres = allBooks
              .map((book) => book.genre)
              .toSet()
              .toList()
            ..sort();

          final selectedGenre = genres.contains(_selectedGenre)
              ? _selectedGenre
              : 'All genres';

          final query = _searchController.text.trim().toLowerCase();

          final books = allBooks.where((book) {
            final matchesQuery =
                query.isEmpty ||
                book.title.toLowerCase().contains(query) ||
                book.author.toLowerCase().contains(query) ||
                book.genre.toLowerCase().contains(query);

            final matchesGenre =
                selectedGenre == 'All genres' || book.genre == selectedGenre;

            return matchesQuery && matchesGenre;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final search = TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search title, author, or genre',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    );

                    final filter = DropdownButtonFormField<String>(
                      initialValue: selectedGenre,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Genre',
                        prefixIcon: Icon(Icons.filter_list_rounded),
                      ),
                      items: ['All genres', ...genres].map((genre) {
                        return DropdownMenuItem<String>(
                          value: genre,
                          child: Text(
                            genre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (genre) {
                        setState(() {
                          _selectedGenre = genre ?? 'All genres';
                        });
                      },
                    );

                    if (constraints.maxWidth >= 600) {
                      return Row(
                        children: [
                          Expanded(child: search),
                          const SizedBox(width: 12),
                          Flexible(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth: 180,
                                maxWidth: 220,
                              ),
                              child: filter,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        search,
                        const SizedBox(height: 10),
                        SizedBox(width: double.infinity, child: filter),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: books.isEmpty
                    ? const Center(
                        child: Text('No books match your search.'),
                      )
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: books.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final book = books[index];

                          return _BookAdminRow(
                            book: book,
                            onEdit: () => _editBook(context, book),
                            onDelete: () => _deleteBook(context, book),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _editBook(BuildContext context, [Book? book]) async {
    final result = await showDialog<Book>(
      context: context,
      builder: (_) => _BookFormDialog(book: book),
    );

    if (result == null) return;

    final service = MockBookService.instance;

    if (book == null) {
      service.addBook(result);
    } else {
      service.updateBook(result);
    }
  }

  Future<void> _deleteBook(BuildContext context, Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text('Delete "${book.title}" from the catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      MockBookService.instance.deleteBook(book.id);
    }
  }
}

class _BookAdminRow extends StatelessWidget {
  final Book book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BookAdminRow({
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final flags = [
      if (book.isBestseller) 'Bestseller',
      if (book.isNewArrival) 'New arrival',
      if (book.isFeatured) 'Featured',
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              book.coverUrl,
              width: 58,
              height: 78,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 58,
                height: 78,
                color: colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: const Icon(Icons.menu_book_rounded),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  '${book.author} · ${book.genre}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  children: [
                    Text(_money(book.price)),
                    Text(
                      'Stock ${book.stock}',
                      style: TextStyle(
                        color: book.stock < 5
                            ? colorScheme.error
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (flags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    flags.join(' · '),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Book actions',
            onSelected: (action) =>
                action == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookFormDialog extends StatefulWidget {
  final Book? book;

  const _BookFormDialog({this.book});

  @override
  State<_BookFormDialog> createState() => _BookFormDialogState();
}

class _BookFormDialogState extends State<_BookFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _genreController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _coverController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  late bool _isBestseller;
  late bool _isNewArrival;
  late bool _isFeatured;

  @override
  void initState() {
    super.initState();

    final book = widget.book;

    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _genreController = TextEditingController(text: book?.genre ?? '');
    _descriptionController = TextEditingController(
      text: book?.description ?? '',
    );
    _coverController = TextEditingController(
      text: book?.coverUrl ?? '',
    );
    _priceController = TextEditingController(
      text: book == null ? '' : book.price.toStringAsFixed(0),
    );
    _stockController = TextEditingController(
      text: book == null ? '0' : '${book.stock}',
    );

    _isBestseller = book?.isBestseller ?? false;
    _isNewArrival = book?.isNewArrival ?? false;
    _isFeatured = book?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _descriptionController.dispose();
    _coverController.dispose();
    _priceController.dispose();
    _stockController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.book == null ? 'Add book' : 'Edit book'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _textField(_titleController, 'Title'),
                _textField(_authorController, 'Author'),
                _textField(_genreController, 'Genre'),
                _textField(
                  _descriptionController,
                  'Description',
                  maxLines: 3,
                ),
                _textField(
                  _coverController,
                  'Cover image URL',
                  required: false,
                  keyboardType: TextInputType.url,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        _priceController,
                        'Price (₦)',
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _validatePrice,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _textField(
                        _stockController,
                        'Stock',
                        keyboardType: TextInputType.number,
                        validator: _validateStock,
                      ),
                    ),
                  ],
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Bestseller'),
                  value: _isBestseller,
                  onChanged: (value) {
                    setState(() {
                      _isBestseller = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('New arrival'),
                  value: _isNewArrival,
                  onChanged: (value) {
                    setState(() {
                      _isNewArrival = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Featured'),
                  value: _isFeatured,
                  onChanged: (value) {
                    setState(() {
                      _isFeatured = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save book'),
        ),
      ],
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    bool required = true,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator:
            validator ??
            (value) =>
                required &&
                    (value == null || value.trim().isEmpty)
                ? 'Required'
                : null,
      ),
    );
  }

  String? _validatePrice(String? value) {
    final price = double.tryParse(value?.trim() ?? '');

    if (price == null || price <= 0) {
      return 'Enter a price above zero';
    }

    return null;
  }

  String? _validateStock(String? value) {
    final stock = int.tryParse(value?.trim() ?? '');

    if (stock == null || stock < 0) {
      return 'Enter zero or more';
    }

    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final existing = widget.book;

    final book = Book(
      id: existing?.id ?? 'admin-${DateTime.now().microsecondsSinceEpoch}',
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      genre: _genreController.text.trim(),
      description: _descriptionController.text.trim(),
      coverUrl: _coverController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      rating: existing?.rating ?? 0,
      reviewCount: existing?.reviewCount ?? 0,
      isBestseller: _isBestseller,
      isNewArrival: _isNewArrival,
      isFeatured: _isFeatured,
    );

    Navigator.pop(context, book);
  }
}

String _money(double amount) {
  return NumberFormat.currency(
    locale: 'en_NG',
    symbol: '₦',
    decimalDigits: 0,
  ).format(amount);
}
