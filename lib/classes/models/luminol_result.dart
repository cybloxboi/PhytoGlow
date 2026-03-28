import 'dart:typed_data';

class LuminolResult {
  const LuminolResult({
    required this.previewBytes,
    required this.area,
    required this.meanIntensity,
    required this.maxIntensity,
    this.intensityPercentOverride,
  });

  final Uint8List previewBytes;
  final int area;
  final double meanIntensity;
  final int maxIntensity;
  final double? intensityPercentOverride;

  Uint8List get thresholdedBytes => previewBytes;

  double get normalizedMeanIntensity => (meanIntensity / 255.0).clamp(0.0, 1.0);

  double get intensityPercent =>
      intensityPercentOverride ??
      (normalizedMeanIntensity * 100).clamp(0.0, 100.0);
}
