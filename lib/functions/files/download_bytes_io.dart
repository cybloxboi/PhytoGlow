import 'dart:io';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

const MethodChannel _downloadChannel = MethodChannel(
  'io.cyblox.phyto_glow/downloads',
);

Future<void> downloadBytes({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) async {
  if (bytes.isEmpty) {
    throw StateError('ไม่มีข้อมูลไฟล์สำหรับดาวน์โหลด');
  }

  if (Platform.isAndroid) {
    await _downloadChannel.invokeMethod<void>('saveBytes', <String, Object>{
      'bytes': bytes,
      'fileName': fileName,
      'mimeType': mimeType,
    });
    return;
  }

  final result = await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: mimeType, name: fileName)],
      fileNameOverrides: [fileName],
    ),
  );

  if (result.status == ShareResultStatus.dismissed) {
    throw StateError('ยกเลิกการบันทึกไฟล์');
  }
}
