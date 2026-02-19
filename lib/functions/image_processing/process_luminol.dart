import 'package:image/image.dart' as img;
import 'package:phyto_glow/classes/luminol_result.dart';
import 'package:phyto_glow/functions/colors/rgb_to_hsv.dart';
import 'is_luminol_pixel.dart';

LuminolResult processLuminol(img.Image src) {
  final width = src.width;
  final height = src.height;
  final totalPixels = width * height;
  double sumLumV = 0;
  int countLum = 0;
  final result = img.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final p = src.getPixel(x, y);
      final hsv = rgbToHsv(p.r.toInt(), p.g.toInt(), p.b.toInt());
      final h = hsv[0];
      final s = hsv[1];
      final v = hsv[2];

      if (isLuminolPixel(h, s, v)) {
        result.setPixelRgb(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt());
        sumLumV += v;
        countLum++;
      } else {
        result.setPixelRgb(x, y, 0, 0, 0);
      }
    }
  }

  double intensityPercent = 0;

  if (countLum > 0) {
    double areaRatio = countLum / totalPixels;

    if (areaRatio < 0.001) {
      intensityPercent = 0;
    } else {
      intensityPercent = (sumLumV / totalPixels) * 100;
      intensityPercent = intensityPercent.clamp(0.0, 100.0);
    }
  }

  return LuminolResult(result, intensityPercent);
}
