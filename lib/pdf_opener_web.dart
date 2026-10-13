import 'dart:typed_data';
import 'dart:html' as html;

void openPdfInBrowserImpl(Uint8List bytes, String fileName) {
  print('openPdfInBrowserImpl called with file: $fileName');
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  print('Created blob URL: $url');
  html.window.open(url, '_blank');
  print('Called window.open');
}

void downloadPdfImpl(Uint8List bytes, String fileName) {
  print('downloadPdfImpl called with file: $fileName');
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  print('Created blob URL: $url');
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  print('Clicked anchor');
  html.Url.revokeObjectUrl(url);
  print('Revoked URL');
}
