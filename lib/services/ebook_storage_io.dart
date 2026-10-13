import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<File> _ebookFile(String bookId, String extension) async {
  final directory = await getApplicationDocumentsDirectory();
  final ebookDirectory = Directory('${directory.path}/ebooks');
  await ebookDirectory.create(recursive: true);
  return File('${ebookDirectory.path}/$bookId.$extension');
}

Future<Uint8List?> loadDownloadedEbook(String bookId, String extension) async {
  final file = await _ebookFile(bookId, extension);
  return await file.exists() ? file.readAsBytes() : null;
}

Future<void> saveDownloadedEbook(
  String bookId,
  String extension,
  Uint8List bytes,
) async {
  await (await _ebookFile(bookId, extension)).writeAsBytes(bytes, flush: true);
}
