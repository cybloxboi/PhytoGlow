import 'dart:typed_data';

import 'package:phyto_glow/functions/files/download_bytes_io.dart'
    if (dart.library.html) 'package:phyto_glow/functions/files/download_bytes_web.dart'
    as downloader_impl;

Future<void> downloadBytes({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) {
  return downloader_impl.downloadBytes(
    bytes: bytes,
    fileName: fileName,
    mimeType: mimeType,
  );
}
