import 'dart:typed_data';

import 'package:opencv_dart/opencv.dart' as cv;
import 'package:phyto_glow/classes/models/luminol_result.dart';
import 'package:phyto_glow/functions/image_processing/get_roi.dart';
import 'package:phyto_glow/functions/image_processing/process_luminol.dart';

Future<LuminolResult> analyzeFluorescent(Uint8List imageBytes) async {
  if (imageBytes.isEmpty) {
    throw StateError('ไม่พบข้อมูลรูปภาพสำหรับวิเคราะห์');
  }

  final source = cv.imdecode(imageBytes, cv.IMREAD_COLOR);

  if (source.isEmpty) {
    source.dispose();
    throw StateError('ไม่สามารถอ่านข้อมูลรูปภาพได้');
  }

  final roi = getROI(source);

  try {
    return processLuminol(roi);
  } finally {
    roi.dispose();
    source.dispose();
  }
}
