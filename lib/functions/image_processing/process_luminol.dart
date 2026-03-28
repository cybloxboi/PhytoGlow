import 'package:opencv_dart/opencv.dart' as cv;
import 'package:phyto_glow/classes/models/luminol_result.dart';
import 'package:phyto_glow/functions/image_processing/process_luminol_shared.dart';

LuminolResult processLuminol(cv.Mat src) {
  final width = src.width;
  final height = src.height;
  final totalPixels = width * height;
  double intensityPercent = 0;

  final hsv = cv.cvtColor(src, cv.COLOR_BGR2HSV);
  final mask = cv.inRangebyScalar(
    hsv,
    cv.Scalar(100, 64, 102, 0),
    cv.Scalar(130, 255, 255, 0),
  );
  final thresholded = cv.bitwiseAND(src, src, mask: mask);

  final countLum = cv.countNonZero(mask);

  if (countLum > 0) {
    final vChannel = cv.extractChannel(hsv, 2);
    final meanV = cv.mean(vChannel, mask: mask).val1;
    intensityPercent = computeLuminolIntensityPercent(
      matchedPixels: countLum,
      totalPixels: totalPixels,
      meanValueNormalized: meanV / 255.0,
    );
    vChannel.dispose();
  }

  final (_, thresholdedBytes) = cv.imencode('.jpg', thresholded);
  hsv.dispose();
  mask.dispose();
  thresholded.dispose();

  return LuminolResult(thresholdedBytes, intensityPercent);
}
