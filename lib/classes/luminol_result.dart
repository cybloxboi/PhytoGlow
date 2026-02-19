import 'package:image/image.dart' as img;

class LuminolResult {
  final img.Image thresholdedImage;
  final double intensityPercent;

  LuminolResult(this.thresholdedImage, this.intensityPercent);
}
