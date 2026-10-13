export 'ebook_storage_stub.dart'
    if (dart.library.io) 'ebook_storage_io.dart'
    if (dart.library.html) 'ebook_storage_web.dart';
