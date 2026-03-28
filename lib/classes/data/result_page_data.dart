import 'dart:typed_data';

import 'package:phyto_glow/classes/models/luminol_result.dart';
import 'package:phyto_glow/classes/roboflow/roboflow_inference_result.dart';

enum ResultAnalysisType { fluorescent, wbc }

class ResultPageData {
  const ResultPageData._({
    required this.imageBytes,
    required this.imageName,
    required this.analysisType,
    this.wbcResult,
    this.fluorescentResult,
  });

  const ResultPageData.fluorescent({
    required Uint8List imageBytes,
    required String imageName,
    required LuminolResult result,
  }) : this._(
         imageBytes: imageBytes,
         imageName: imageName,
         analysisType: ResultAnalysisType.fluorescent,
         fluorescentResult: result,
       );

  const ResultPageData.wbc({
    required Uint8List imageBytes,
    required String imageName,
    required RoboflowInferenceResult result,
  }) : this._(
         imageBytes: imageBytes,
         imageName: imageName,
         analysisType: ResultAnalysisType.wbc,
         wbcResult: result,
       );

  final Uint8List imageBytes;
  final String imageName;
  final ResultAnalysisType analysisType;
  final RoboflowInferenceResult? wbcResult;
  final LuminolResult? fluorescentResult;

  bool get isFluorescent => analysisType == ResultAnalysisType.fluorescent;

  bool get isWbc => analysisType == ResultAnalysisType.wbc;
}
