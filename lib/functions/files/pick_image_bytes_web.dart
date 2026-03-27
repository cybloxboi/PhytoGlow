import 'dart:async';
import 'dart:js_interop';

import 'package:phyto_glow/classes/data/picked_image_data.dart';
import 'package:web/web.dart' as web;

Future<PickedImageData?> pickImageBytes() async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'image/*'
    ..multiple = false;

  input.style
    ..position = 'fixed'
    ..top = '0'
    ..left = '0'
    ..width = '1px'
    ..height = '1px'
    ..opacity = '0'
    ..overflow = 'hidden'
    ..pointerEvents = 'none';

  web.document.body?.append(input);

  try {
    input.click();
    await input.onChange.first;

    final files = input.files;
    final file = files == null || files.length == 0 ? null : files.item(0);
    if (file == null) return null;

    final reader = web.FileReader();
    final completer = Completer<PickedImageData?>();

    reader.onloadend = ((web.Event _) {
      final bytes = (reader.result as JSArrayBuffer?)?.toDart.asUint8List();
      if (bytes == null) {
        completer.complete(null);
        return;
      }

      completer.complete(
        PickedImageData(
          name: file.name.isEmpty ? 'เลือกรูปภาพแล้ว' : file.name,
          bytes: bytes,
        ),
      );
    }).toJS;

    reader.onerror = ((web.Event _) {
      if (!completer.isCompleted) {
        final message = reader.error?.message;
        completer.completeError(
          StateError(message ?? 'ไม่สามารถอ่านไฟล์รูปภาพบนเว็บได้'),
        );
      }
    }).toJS;

    reader.readAsArrayBuffer(file);
    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => null,
    );
  } finally {
    input.remove();
  }
}
