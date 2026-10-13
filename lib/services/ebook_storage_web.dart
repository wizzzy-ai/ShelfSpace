import 'dart:typed_data';

final Map<String, Uint8List> _downloadedEbooks = {};

String _key(String bookId, String extension) => '$bookId.$extension';

Future<Uint8List?> loadDownloadedEbook(String bookId, String extension) async =>
    _downloadedEbooks[_key(bookId, extension)];

Future<void> saveDownloadedEbook(
  String bookId,
  String extension,
  Uint8List bytes,
) async {
  _downloadedEbooks[_key(bookId, extension)] = bytes;
}
