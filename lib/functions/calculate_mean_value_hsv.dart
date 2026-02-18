import 'package:image/image.dart' as img;
import 'package:phyto_glow/functions/rgb_to_hsv.dart';

double calculateMeanValueHSV(img.Image image) {
  double sumV = 0;
  int count = 0;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      int r = pixel.r.toInt();
      int g = pixel.g.toInt();
      int b = pixel.b.toInt();
      final hsv = rgbToHsv(r, g, b);
      double h = hsv[0];
      double s = hsv[1];
      double v = hsv[2];

      if (h > 180 && h < 260 && s > 0.2 && v > 0.2) {
        sumV += v;
        count++;
      }
    }
  }

  return count == 0 ? 0 : sumV / count;
}
