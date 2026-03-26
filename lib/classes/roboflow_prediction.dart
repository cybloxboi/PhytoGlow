class RoboflowPrediction {
  final String label;
  final double confidence;
  final double? x;
  final double? y;
  final double? width;
  final double? height;

  const RoboflowPrediction({
    required this.label,
    required this.confidence,
    this.x,
    this.y,
    this.width,
    this.height,
  });

  factory RoboflowPrediction.fromJson(Map<String, dynamic> json) {
    return RoboflowPrediction(
      label: (json['class'] ?? json['label'] ?? 'unknown').toString(),
      confidence: _toDouble(json['confidence']) ?? 0.0,
      x: _toDouble(json['x']),
      y: _toDouble(json['y']),
      width: _toDouble(json['width']),
      height: _toDouble(json['height']),
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
