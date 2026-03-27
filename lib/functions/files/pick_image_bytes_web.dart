// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:phyto_glow/classes/data/picked_image_data.dart';

Future<PickedImageData?> pickImageBytes() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false
    ..style.position = 'fixed'
    ..style.left = '-9999px'
    ..style.top = '0'
    ..style.width = '1px'
    ..style.height = '1px'
    ..style.opacity = '0'
    ..style.pointerEvents = 'none';

  html.document.body?.append(input);

  try {
    input.click();
    await input.onChange.first;

    final files = input.files;
    final file = files == null || files.isEmpty ? null : files.first;
    if (file == null) return null;

    final reader = html.FileReader();
    final completer = Completer<PickedImageData?>();

    reader.onLoadEnd.first.then((_) {
      final result = reader.result;
      if (result is Uint8List) {
        completer.complete(
          PickedImageData(
            name: file.name.isEmpty ? 'เลือกรูปภาพแล้ว' : file.name,
            bytes: result,
          ),
        );
        return;
      }

      if (result is List<int>) {
        completer.complete(
          PickedImageData(
            name: file.name.isEmpty ? 'เลือกรูปภาพแล้ว' : file.name,
            bytes: Uint8List.fromList(result),
          ),
        );
        return;
      }

      completer.complete(null);
    });

    reader.onError.first.then((_) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('ไม่สามารถอ่านไฟล์รูปภาพบนเว็บได้'));
      }
    });

    reader.readAsArrayBuffer(file);
    return await completer.future;
  } finally {
    input.remove();
  }
}
