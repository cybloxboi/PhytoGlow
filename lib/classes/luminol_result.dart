import 'dart:typed_data';

class LuminolResult {
  final Uint8List thresholdedBytes;
  final double intensityPercent;

  LuminolResult(this.thresholdedBytes, this.intensityPercent);
}
