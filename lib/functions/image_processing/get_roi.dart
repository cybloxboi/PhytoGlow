import 'package:opencv_dart/opencv.dart' as cv;

cv.Mat getROI(cv.Mat src) {
  final width = src.width;
  final height = src.height;
  final totalArea = width * height;

  final hsv = cv.cvtColor(src, cv.COLOR_BGR2HSV);
  final mask = cv.inRangebyScalar(
    hsv,
    cv.Scalar(90, 40, 40, 0),
    cv.Scalar(140, 255, 255, 0),
  );
  final kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (7, 7));
  final opened = cv.morphologyEx(mask, cv.MORPH_OPEN, kernel, iterations: 1);
  final cleaned = cv.morphologyEx(
    opened,
    cv.MORPH_CLOSE,
    kernel,
    iterations: 2,
  );
  final contourInput = cv.Mat.fromMat(cleaned, copy: true);

  final (contours, hierarchy) = cv.findContours(
    contourInput,
    cv.RETR_EXTERNAL,
    cv.CHAIN_APPROX_SIMPLE,
  );

  cv.Rect? bestRect;
  var bestArea = 0.0;

  for (int i = 0; i < contours.length; i++) {
    final contour = contours[i];
    final area = cv.contourArea(contour);
    if (area > bestArea) {
      bestArea = area;
      bestRect = cv.boundingRect(contour);
    }
  }

  hsv.dispose();
  mask.dispose();
  kernel.dispose();
  opened.dispose();
  cleaned.dispose();
  contourInput.dispose();
  contours.dispose();
  hierarchy.dispose();

  if (bestRect != null && bestArea >= totalArea * 0.002) {
    final expanded = _expandRect(
      bestRect,
      width,
      height,
      padScale: 0.12,
      minWidth: (width * 0.2).toInt(),
      minHeight: (height * 0.2).toInt(),
    );
    return cv.Mat.fromMat(src, roi: expanded, copy: true);
  }

  return _centerFallbackROI(src);
}

cv.Mat _centerFallbackROI(cv.Mat src) {
  final w = src.width;
  final h = src.height;
  final roiW = (w * 0.4).toInt();
  final roiH = (h * 0.4).toInt();
  final x = (w - roiW) ~/ 2;
  final y = (h - roiH) ~/ 2;
  return cv.Mat.fromMat(src, roi: cv.Rect(x, y, roiW, roiH), copy: true);
}

cv.Rect _expandRect(
  cv.Rect rect,
  int maxWidth,
  int maxHeight, {
  required double padScale,
  required int minWidth,
  required int minHeight,
}) {
  final padX = (rect.width * padScale).toInt();
  final padY = (rect.height * padScale).toInt();

  var x = rect.x - padX;
  var y = rect.y - padY;
  var w = rect.width + (padX * 2);
  var h = rect.height + (padY * 2);

  if (w < minWidth) {
    final diff = minWidth - w;
    x -= diff ~/ 2;
    w = minWidth;
  }
  if (h < minHeight) {
    final diff = minHeight - h;
    y -= diff ~/ 2;
    h = minHeight;
  }

  if (x < 0) x = 0;
  if (y < 0) y = 0;
  if (x + w > maxWidth) w = maxWidth - x;
  if (y + h > maxHeight) h = maxHeight - y;

  return cv.Rect(x, y, w, h);
}
