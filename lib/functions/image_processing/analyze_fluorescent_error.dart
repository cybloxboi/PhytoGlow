import 'dart:typed_data';

import 'package:phyto_glow/classes/models/luminol_result.dart';

Future<LuminolResult> analyzeFluorescent(Uint8List imageBytes) async {
  throw UnsupportedError(
    'การวิเคราะห์ Fluorescent ด้วย OpenCV ยังไม่รองรับบนแพลตฟอร์มนี้',
  );
}
