import 'dart:typed_data';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:epubx/epubx.dart' hide Image;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:pdfx/pdfx.dart';

import '../../pdf_opener.dart';

import '../../models/library_book.dart';
import '../../services/library_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with WidgetsBindingObserver {
  final LibraryService _libraryService = LibraryService();
  List<LibraryBook> _books = [];
  String? _error;
  String? _busyBookId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLibrary();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadLibrary();
    }
  }

  Future<void> _loadLibrary() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final books = await _libraryService.fetchLibrary();
      if (!mounted) return;
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _readBook(LibraryBook book) async {
    setState(() => _busyBookId = book.id);
    try {
      final bytes = await _libraryService.loadEbook(book);
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => EbookReaderScreen(book: book, bytes: bytes),
        ),
      );
    } catch (error) {
      if (mounted) _showMessage('Could not open ebook: ${error.toString()}');
    } finally {
      if (mounted) setState(() => _busyBookId = null);
    }
  }

  Future<void> _downloadBook(LibraryBook book) async {
    setState(() => _busyBookId = book.id);
    try {
      await _libraryService.downloadToDevice(book);
      if (mounted) _showMessage('Saved "${book.title}" to your device.');
    } catch (error) {
      if (mounted) _showMessage('$error');
    } finally {
      if (mounted) setState(() => _busyBookId = null);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          IconButton(
            tooltip: 'Refresh library',
            onPressed: _isLoading ? null : _loadLibrary,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadLibrary,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            )
          : _books.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'Your books will appear here after an admin confirms your payment.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadLibrary,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _books.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final book = _books[index];
                  final isBusy = _busyBookId == book.id;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              book.coverUrl,
                              width: 58,
                              height: 78,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const SizedBox(
                                width: 58,
                                height: 78,
                                child: Icon(Icons.menu_book_rounded),
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                Text(book.author),
                                const SizedBox(height: 4),
                                book.hasFile
                                    ? Text('${book.format} · Saved after first read')
                                    : const Text('File not yet uploaded', style: TextStyle(color: Colors.orange)),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FilledButton.tonalIcon(
                                      onPressed: isBusy || !book.hasFile
                                          ? null
                                          : () => _readBook(book),
                                      icon: const Icon(
                                        Icons.menu_book_outlined,
                                      ),
                                      label: Text(isBusy ? 'Opening…' : 'Read'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: isBusy || !book.hasFile
                                          ? null
                                          : () => _downloadBook(book),
                                      icon: const Icon(Icons.download_rounded),
                                      label: const Text('Download'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class EbookReaderScreen extends StatefulWidget {
  const EbookReaderScreen({super.key, required this.book, required this.bytes});

  final LibraryBook book;
  final Uint8List bytes;

  @override
  State<EbookReaderScreen> createState() => _EbookReaderScreenState();
}

class _EbookReaderScreenState extends State<EbookReaderScreen> {
  PdfControllerPinch? _pdfController;
  Future<EpubBook>? _epubDocument;
  String? _errorMessage;
  String? _pdfUrl;

  @override
  void initState() {
    super.initState();
    try {
      if (widget.book.format == 'EPUB') {
        _epubDocument = EpubReader.readBook(widget.bytes);
      } else {
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openData(widget.bytes),
        );
      }
    } catch (error) {
      print('Error initializing PDF reader: $error');
      setState(() => _errorMessage = error.toString());
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Widget _buildEpubReader() {
    return FutureBuilder<EpubBook>(
      future: _epubDocument,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not open this EPUB: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final chapters = _flattenChapters(snapshot.data?.Chapters);
        final content = chapters
            .map((chapter) {
              final text = html_parser
                  .parse(chapter.HtmlContent ?? '')
                  .body
                  ?.text
                  .trim();
              if (text == null || text.isEmpty) return null;
              return (title: chapter.Title?.trim() ?? '', text: text);
            })
            .whereType<({String title, String text})>()
            .toList();

        if (content.isEmpty) {
          return const Center(child: Text('This EPUB has no readable text.'));
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            for (final chapter in content) ...[
              if (chapter.title.isNotEmpty) ...[
                Text(
                  chapter.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
              ],
              SelectableText(
                chapter.text,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(height: 1.7),
              ),
              const SizedBox(height: 28),
            ],
          ],
        );
      },
    );
  }

  List<EpubChapter> _flattenChapters(List<EpubChapter>? chapters) {
    if (chapters == null) return [];
    return [
      for (final chapter in chapters) ...[
        chapter,
        ..._flattenChapters(chapter.SubChapters),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error opening ebook',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _downloadToFile,
                      icon: const Icon(Icons.download),
                      label: const Text('Download file instead'),
                    ),
                  ],
                ),
              ),
            )
          : kIsWeb && widget.book.format == 'PDF'
              ? _buildWebPdfViewer()
              : widget.book.format == 'PDF'
                  ? PdfViewPinch(controller: _pdfController!)
                  : _buildEpubReader(),
    );
  }

  Widget _buildWebPdfViewer() {
    // Create blob URL if not already created
    if (_pdfUrl == null) {
      final blob = html.Blob([widget.bytes], 'application/pdf');
      _pdfUrl = html.Url.createObjectUrlFromBlob(blob);
    }

    // Create iframe element with responsive styling
    final iframe = html.IFrameElement()
      ..src = _pdfUrl!
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..style.overflow = 'auto'
      ..style.position = 'absolute'
      ..style.top = '0'
      ..style.left = '0';

    // Register the iframe as a view
    final viewType = 'pdf-viewer-${DateTime.now().millisecondsSinceEpoch}';
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => iframe,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            children: [
              HtmlElementView(viewType: viewType),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _openPdfInBrowser,
                        icon: const Icon(Icons.open_in_new, color: Colors.white),
                        tooltip: 'Open in new tab',
                        iconSize: 20,
                      ),
                      IconButton(
                        onPressed: _downloadToFile,
                        icon: const Icon(Icons.download, color: Colors.white),
                        tooltip: 'Download',
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPdfInBrowser() {
    print('Opening PDF in browser...');
    try {
      openPdfInBrowser(widget.bytes, widget.book.fileName);
      print('PDF opened successfully');
    } catch (e) {
      print('Error opening PDF: $e');
      setState(() => _errorMessage = 'Failed to open PDF: $e');
    }
  }

  void _downloadToFile() {
    print('Downloading PDF...');
    try {
      downloadPdf(widget.bytes, widget.book.fileName);
      print('PDF downloaded successfully');
    } catch (e) {
      print('Error downloading PDF: $e');
      setState(() => _errorMessage = 'Failed to download: $e');
    }
  }
}
