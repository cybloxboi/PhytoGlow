import 'dart:typed_data';

import 'package:phyto_glow/classes/roboflow/roboflow_inference_result.dart';

class ResultPageData {
  const ResultPageData({
    required this.imageBytes,
    required this.imageName,
    required this.result,
  });

  final Uint8List imageBytes;
  final String imageName;
  final RoboflowInferenceResult result;
}
