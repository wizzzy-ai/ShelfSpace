import 'dart:typed_data';

import 'pdf_opener_web.dart' if (dart.library.io) 'pdf_opener_io.dart';

void openPdfInBrowser(Uint8List bytes, String fileName) {
  openPdfInBrowserImpl(bytes, fileName);
}

void downloadPdf(Uint8List bytes, String fileName) {
  downloadPdfImpl(bytes, fileName);
}
