import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

Uint8List yuv420ToImage(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel!;
  final img.Image rgbImage = img.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    final uvRow = uvRowStride * (y >> 1);

    for (int x = 0; x < width; x++) {
      final int uvIndex = uvRow + (x >> 1) * uvPixelStride;
      final int index = y * width + x;
      final int yp = image.planes[0].bytes[index];
      final int up = image.planes[1].bytes[uvIndex];
      final int vp = image.planes[2].bytes[uvIndex];
      int r = (yp + 1.402 * (vp - 128)).round();
      int g = (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128)).round();
      int b = (yp + 1.772 * (up - 128)).round();
      r = r.clamp(0, 255);
      g = g.clamp(0, 255);
      b = b.clamp(0, 255);

      rgbImage.setPixelRgb(x, y, r, g, b);
    }
  }

  return Uint8List.fromList(img.encodeJpg(rgbImage));
}
