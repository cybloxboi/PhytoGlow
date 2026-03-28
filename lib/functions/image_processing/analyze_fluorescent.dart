import 'dart:typed_data';

import 'package:phyto_glow/classes/models/luminol_result.dart';
import 'package:phyto_glow/functions/image_processing/analyze_fluorescent_error.dart'
    if (dart.library.html) 'package:phyto_glow/functions/image_processing/analyze_fluorescent_web.dart'
    if (dart.library.io) 'package:phyto_glow/functions/image_processing/analyze_fluorescent_io.dart'
    as analyzer_impl;

Future<LuminolResult> analyzeFluorescent(Uint8List imageBytes) {
  return analyzer_impl.analyzeFluorescent(imageBytes);
}
