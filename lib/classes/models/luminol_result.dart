import 'dart:typed_data';

class LuminolResult {
  const LuminolResult({
    required this.previewBytes,
    required this.intensityPercent,
    required this.areaPercent,
    required this.snr,
    required this.meanForeground,
    required this.meanBackground,
    required this.otsuThreshold,
    required this.regionCount,
    required this.largestAreaPx,
  });

  final Uint8List previewBytes;
  final double intensityPercent;
  final double areaPercent;
  final double snr;
  final double meanForeground;
  final double meanBackground;
  final double otsuThreshold;
  final int regionCount;
  final int largestAreaPx;
}
