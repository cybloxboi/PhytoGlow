import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:opencv_dart/opencv.dart' as cv;

cv.Mat cameraImageToBgrMat(CameraImage image) {
  switch (image.format.group) {
    case ImageFormatGroup.yuv420:
      return _yuv420ToBgrMat(image);
    case ImageFormatGroup.bgra8888:
      return _bgra8888ToBgrMat(image);
    default:
      throw UnsupportedError(
        'Unsupported camera format: ${image.format.group}. Expected yuv420 or bgra8888.',
      );
  }
}

cv.Mat _yuv420ToBgrMat(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final yPlane = image.planes[0];
  final uPlane = image.planes[1];
  final vPlane = image.planes[2];
  final uvHeight = height ~/ 2;
  final uvWidth = width ~/ 2;
  final uvPixelStride = uPlane.bytesPerPixel ?? 1;
  final nv21 = Uint8List((width * height * 3) ~/ 2);

  for (int y = 0; y < height; y++) {
    final srcStart = y * yPlane.bytesPerRow;
    final dstStart = y * width;
    nv21.setRange(dstStart, dstStart + width, yPlane.bytes, srcStart);
  }

  final chromaOffset = width * height;
  for (int y = 0; y < uvHeight; y++) {
    final uRowStart = y * uPlane.bytesPerRow;
    final vRowStart = y * vPlane.bytesPerRow;
    final dstRowStart = chromaOffset + (y * width);
    for (int x = 0; x < uvWidth; x++) {
      final srcIndex = x * uvPixelStride;
      final dstIndex = dstRowStart + (x * 2);
      nv21[dstIndex] = vPlane.bytes[vRowStart + srcIndex];
      nv21[dstIndex + 1] = uPlane.bytes[uRowStart + srcIndex];
    }
  }

  final yuv = cv.Mat.fromList(
    height + uvHeight,
    width,
    cv.MatType.CV_8UC1,
    nv21,
  );
  final bgr = cv.cvtColor(yuv, cv.COLOR_YUV2BGR_NV21);
  yuv.dispose();
  return bgr;
}

cv.Mat _bgra8888ToBgrMat(CameraImage image) {
  final width = image.width;
  final height = image.height;
  final bgraPlane = image.planes.first;
  final bgraBytes = Uint8List(width * height * 4);

  for (int y = 0; y < height; y++) {
    final srcStart = y * bgraPlane.bytesPerRow;
    final dstStart = y * width * 4;
    bgraBytes.setRange(
      dstStart,
      dstStart + (width * 4),
      bgraPlane.bytes,
      srcStart,
    );
  }

  final bgra = cv.Mat.fromList(height, width, cv.MatType.CV_8UC4, bgraBytes);
  final bgr = cv.cvtColor(bgra, cv.COLOR_BGRA2BGR);
  bgra.dispose();
  return bgr;
}
