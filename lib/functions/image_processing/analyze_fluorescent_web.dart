import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:phyto_glow/classes/models/luminol_result.dart';
import 'package:phyto_glow/functions/image_processing/process_luminol_web.dart';

Future<LuminolResult> analyzeFluorescent(Uint8List imageBytes) async {
  if (imageBytes.isEmpty) {
    throw StateError('ไม่พบข้อมูลรูปภาพสำหรับวิเคราะห์');
  }

  final source = img.decodeImage(imageBytes);
  if (source == null) {
    throw StateError('ไม่สามารถอ่านข้อมูลรูปภาพได้');
  }

  final roi = _findRoi(source);
  final roiImage = img.copyCrop(
    source,
    x: roi.x,
    y: roi.y,
    width: roi.width,
    height: roi.height,
  );

  return processLuminolWeb(roiImage);
}

_Rect _findRoi(img.Image image) {
  final width = image.width;
  final height = image.height;
  final totalArea = width * height;

  var minX = width;
  var minY = height;
  var maxX = -1;
  var maxY = -1;
  var matchedPixels = 0;

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final pixel = image.getPixel(x, y);
      final hsv = _toHsv(
        pixel.r.toDouble(),
        pixel.g.toDouble(),
        pixel.b.toDouble(),
      );
      final isCandidate =
          hsv.hue >= 180 &&
          hsv.hue <= 280 &&
          hsv.saturation >= (40 / 255.0) &&
          hsv.value >= (40 / 255.0);

      if (!isCandidate) {
        continue;
      }

      matchedPixels++;
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
  }

  if (maxX >= minX &&
      maxY >= minY &&
      matchedPixels.toDouble() >= totalArea * 0.002) {
    final rect = _Rect(minX, minY, (maxX - minX) + 1, (maxY - minY) + 1);

    return _expandRect(
      rect,
      maxWidth: width,
      maxHeight: height,
      padScale: 0.12,
      minWidth: math.max(1, (width * 0.2).round()),
      minHeight: math.max(1, (height * 0.2).round()),
    );
  }

  return _centerFallbackRoi(width, height);
}

_Rect _centerFallbackRoi(int width, int height) {
  final roiWidth = math.max(1, (width * 0.4).round());
  final roiHeight = math.max(1, (height * 0.4).round());
  final x = (width - roiWidth) ~/ 2;
  final y = (height - roiHeight) ~/ 2;
  return _Rect(x, y, roiWidth, roiHeight);
}

_Rect _expandRect(
  _Rect rect, {
  required int maxWidth,
  required int maxHeight,
  required double padScale,
  required int minWidth,
  required int minHeight,
}) {
  final padX = (rect.width * padScale).round();
  final padY = (rect.height * padScale).round();

  var x = rect.x - padX;
  var y = rect.y - padY;
  var width = rect.width + (padX * 2);
  var height = rect.height + (padY * 2);

  if (width < minWidth) {
    final diff = minWidth - width;
    x -= diff ~/ 2;
    width = minWidth;
  }

  if (height < minHeight) {
    final diff = minHeight - height;
    y -= diff ~/ 2;
    height = minHeight;
  }

  x = x.clamp(0, math.max(0, maxWidth - 1));
  y = y.clamp(0, math.max(0, maxHeight - 1));
  width = math.min(width, maxWidth - x);
  height = math.min(height, maxHeight - y);

  return _Rect(x, y, math.max(1, width), math.max(1, height));
}

_HsvColor _toHsv(double r, double g, double b) {
  final red = r / 255.0;
  final green = g / 255.0;
  final blue = b / 255.0;
  final maxValue = math.max(red, math.max(green, blue));
  final minValue = math.min(red, math.min(green, blue));
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

class _Rect {
  const _Rect(this.x, this.y, this.width, this.height);

  final int x;
  final int y;
  final int width;
  final int height;
}

class _HsvColor {
  const _HsvColor(this.hue, this.saturation, this.value);

  final double hue;
  final double saturation;
  final double value;
}
