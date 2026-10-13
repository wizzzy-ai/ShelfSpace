class LibraryBook {
  const LibraryBook({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.format,
    required this.fileName,
    required this.hasFile,
  });

  factory LibraryBook.fromJson(Map<String, dynamic> json) => LibraryBook(
    id: json['id'] as String? ?? '',
    title: json['title'] as String? ?? 'Untitled',
    author: json['author'] as String? ?? 'Unknown author',
    coverUrl: json['coverUrl'] as String? ?? '',
    format: json['format'] as String? ?? 'PDF',
    fileName: json['fileName'] as String? ?? 'ebook',
    hasFile: json['hasFile'] as bool? ?? false,
  );

  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String format;
  final String fileName;
  final bool hasFile;

  String get extension => format.toLowerCase();
  String get mimeType =>
      format == 'PDF' ? 'application/pdf' : 'application/epub+zip';
}
