import 'package:image/image.dart' as img;
import 'package:phyto_glow/functions/rgb_to_hsv.dart';

img.Image applyColorThreshold(img.Image src) {
  final result = img.Image(width: src.width, height: src.height);
  double sumV = 0;
  int total = src.width * src.height;

  for (int y = 0; y < src.height; y++) {
    for (int x = 0; x < src.width; x++) {
      final p = src.getPixel(x, y);
      final hsv = rgbToHsv(p.r.toInt(), p.g.toInt(), p.b.toInt());
      sumV += hsv[2];
    }
  }

  double meanV = sumV / total;

  for (int y = 0; y < src.height; y++) {
    for (int x = 0; x < src.width; x++) {
      final pixel = src.getPixel(x, y);
      int r = pixel.r.toInt();
      int g = pixel.g.toInt();
      int b = pixel.b.toInt();
      final hsv = rgbToHsv(r, g, b);
      double h = hsv[0];
      double s = hsv[1];
      double v = hsv[2];
      bool hueMatch = (h > 200 && h < 250);
      bool satMatch = (s > 0.25);
      bool brightMatch = (v > meanV * 1.3);
      bool isLuminol = hueMatch && satMatch && brightMatch;

      if (isLuminol) {
        result.setPixelRgb(x, y, r, g, b);
      } else {
        result.setPixelRgb(x, y, 0, 0, 0);
      }
    }
  }

  return result;
}
