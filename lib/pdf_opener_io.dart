import 'dart:typed_data';

void openPdfInBrowserImpl(Uint8List bytes, String fileName) {
  // Desktop/mobile - not implemented for opening in browser
  throw UnimplementedError('Opening PDF in browser is only available on web');
}

void downloadPdfImpl(Uint8List bytes, String fileName) {
  // Desktop/mobile - use file_picker or similar
  throw UnimplementedError('Download not implemented for this platform');
}
