import 'package:phyto_glow/classes/roboflow/roboflow_prediction.dart';

class RoboflowInferenceResult {
  final List<RoboflowPrediction> predictions;
  final String? topLabel;
  final double? topConfidence;
  final int? imageWidth;
  final int? imageHeight;
  final Map<String, int> classCounts;

  const RoboflowInferenceResult({
    required this.predictions,
    required this.classCounts,
    this.topLabel,
    this.topConfidence,
    this.imageWidth,
    this.imageHeight,
  });

  factory RoboflowInferenceResult.fromJson(Map<String, dynamic> json) {
    final rawPredictions = json['predictions'];
    final predictions = rawPredictions is List
        ? rawPredictions
              .whereType<Map<String, dynamic>>()
              .map(RoboflowPrediction.fromJson)
              .toList()
        : <RoboflowPrediction>[];

    final classCounts = <String, int>{};
    for (final prediction in predictions) {
      classCounts.update(
        prediction.label,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    return RoboflowInferenceResult(
      predictions: predictions,
      classCounts: classCounts,
      topLabel: json['top']?.toString(),
      topConfidence: _toDouble(json['confidence']),
      imageWidth: _toInt(json['image']?['width']),
      imageHeight: _toInt(json['image']?['height']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
