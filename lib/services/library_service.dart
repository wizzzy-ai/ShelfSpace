import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../core/constants/api_constants.dart';
import '../models/library_book.dart';
import 'auth_service.dart';
import 'ebook_storage.dart';

class LibraryService {
  LibraryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final AuthService _authService = AuthService();
  final String _baseUrl = ApiConstants.baseUrl;

  Future<List<LibraryBook>> fetchLibrary() async {
    final token = _authService.token;
    if (token == null) throw Exception('Sign in to view your library.');

    final response = await _client.get(
      Uri.parse('$_baseUrl${ApiConstants.library}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? 'Could not load your library.');
    }
    return ((data['items'] as List?) ?? [])
        .map((item) => LibraryBook.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Uint8List> loadEbook(LibraryBook book) async {
    if (!book.hasFile) {
      throw Exception('This ebook file has not been uploaded yet.');
    }
    final saved = await loadDownloadedEbook(book.id, book.extension);
    if (saved != null) return saved;

    final bytes = await _fetchEbook(book);
    await saveDownloadedEbook(book.id, book.extension, bytes);
    return bytes;
  }

  Future<void> downloadToDevice(LibraryBook book) async {
    if (!book.hasFile) {
      throw Exception('This ebook file has not been uploaded yet.');
    }
    final bytes = await loadEbook(book);
    final saved = await FilePicker.saveFile(
      fileName: book.fileName,
      bytes: bytes,
      mimeType: book.mimeType,
      dialogTitle: 'Save ebook to this device',
    );
    if (saved == null) throw Exception('Download cancelled.');
  }

  Future<Uint8List> _fetchEbook(LibraryBook book) async {
    final token = _authService.token;
    if (token == null) throw Exception('Sign in to read this book.');

    final response = await _client.get(
      Uri.parse('$_baseUrl${ApiConstants.library}/${book.id}/file'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      String message = 'Could not download this ebook.';
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        message = data['error'] as String? ?? message;
      } on FormatException {
        message = 'Could not download this ebook (${response.statusCode}).';
      }
      throw Exception(message);
    }
    return response.bodyBytes;
  }
}
