import 'package:image/image.dart' as img;

img.Image getROI(img.Image src) {
  int w = src.width;
  int h = src.height;
  int roiW = (w * 0.4).toInt();
  int roiH = (h * 0.4).toInt();
  int x = (w - roiW) ~/ 2;
  int y = (h - roiH) ~/ 2;

  return img.copyCrop(src, x: x, y: y, width: roiW, height: roiH);
}
