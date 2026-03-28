import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:phyto_glow/classes/models/luminol_result.dart';
import 'package:phyto_glow/functions/image_processing/process_luminol_shared.dart';

LuminolResult processLuminolWeb(img.Image src) {
  final width = src.width;
  final height = src.height;
  final totalPixels = width * height;
  final thresholded = img.Image(width: width, height: height);

  var matchedPixels = 0;
  var valueSum = 0.0;

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final pixel = src.getPixel(x, y);
      final hsv = _toHsv(
        pixel.r.toDouble(),
        pixel.g.toDouble(),
        pixel.b.toDouble(),
      );

      if (isLuminolHsvNormalized(
        hueDegrees: hsv.hue,
        saturation: hsv.saturation,
        value: hsv.value,
      )) {
        thresholded.setPixelRgb(x, y, pixel.r, pixel.g, pixel.b);
        matchedPixels++;
        valueSum += hsv.value;
      } else {
        thresholded.setPixelRgb(x, y, 0, 0, 0);
      }
    }
  }

  final meanValueNormalized = matchedPixels == 0
      ? 0.0
      : valueSum / matchedPixels;
  final intensityPercent = computeLuminolIntensityPercent(
    matchedPixels: matchedPixels,
    totalPixels: totalPixels,
    meanValueNormalized: meanValueNormalized,
  );

  final thresholdedBytes = Uint8List.fromList(
    img.encodeJpg(thresholded, quality: 92),
  );

  return LuminolResult(thresholdedBytes, intensityPercent);
}

_HsvColor _toHsv(double r, double g, double b) {
  final red = r / 255.0;
  final green = g / 255.0;
  final blue = b / 255.0;
  final maxValue = [red, green, blue].reduce((a, b) => a > b ? a : b);
  final minValue = [red, green, blue].reduce((a, b) => a < b ? a : b);
  final delta = maxValue - minValue;

  var hue = 0.0;
  if (delta != 0) {
    if (maxValue == red) {
      hue = 60 * (((green - blue) / delta) % 6);
    } else if (maxValue == green) {
      hue = 60 * (((blue - red) / delta) + 2);
    } else {
      hue = 60 * (((red - green) / delta) + 4);
    }
  }

  if (hue < 0) {
    hue += 360;
  }

  final saturation = maxValue == 0 ? 0.0 : delta / maxValue;
  return _HsvColor(hue, saturation, maxValue);
}

class _HsvColor {
  const _HsvColor(this.hue, this.saturation, this.value);

  final double hue;
  final double saturation;
  final double value;
}
