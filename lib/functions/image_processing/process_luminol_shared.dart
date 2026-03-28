double get luminolHueMinDegrees => 100 * 2.0;

double get luminolHueMaxDegrees => 130 * 2.0;

double get luminolSaturationMinNormalized => 64 / 255.0;

double get luminolValueMinNormalized => 102 / 255.0;

double get luminolAreaRatioThreshold => 0.001;

bool isLuminolHsvNormalized({
  required double hueDegrees,
  required double saturation,
  required double value,
}) {
  return hueDegrees >= luminolHueMinDegrees &&
      hueDegrees <= luminolHueMaxDegrees &&
      saturation >= luminolSaturationMinNormalized &&
      value >= luminolValueMinNormalized;
}

double computeLuminolIntensityPercent({
  required int matchedPixels,
  required int totalPixels,
  required double meanValueNormalized,
}) {
  if (matchedPixels <= 0 || totalPixels <= 0) {
    return 0;
  }

  final areaRatio = matchedPixels / totalPixels;
  if (areaRatio < luminolAreaRatioThreshold) {
    return 0;
  }

  return (meanValueNormalized * areaRatio * 100).clamp(0.0, 100.0);
}
