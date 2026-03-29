import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../roboflow/roboflow_prediction.dart';

class BoundingBoxPainter extends CustomPainter {
  const BoundingBoxPainter({
    required this.predictions,
    required this.imageWidth,
    required this.imageHeight,
    required this.color,
  });

  final List<RoboflowPrediction> predictions;
  final double? imageWidth;
  final double? imageHeight;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final sourceWidth = imageWidth;
    final sourceHeight = imageHeight;
    if (sourceWidth == null ||
        sourceHeight == null ||
        sourceWidth <= 0 ||
        sourceHeight <= 0) {
      return;
    }

    final scale = math.min(
      size.width / sourceWidth,
      size.height / sourceHeight,
    );
    final drawnWidth = sourceWidth * scale;
    final drawnHeight = sourceHeight * scale;
    final offsetX = (size.width - drawnWidth) / 2;
    final offsetY = (size.height - drawnHeight) / 2;

    final boxPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final labelPaint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    for (final prediction in predictions) {
      if (prediction.x == null ||
          prediction.y == null ||
          prediction.width == null ||
          prediction.height == null) {
        continue;
      }

      final left = offsetX + (prediction.x! - prediction.width! / 2) * scale;
      final top = offsetY + (prediction.y! - prediction.height! / 2) * scale;
      final rect = Rect.fromLTWH(
        left,
        top,
        prediction.width! * scale,
        prediction.height! * scale,
      );

      canvas.drawRect(rect, boxPaint);

      final textSpan = TextSpan(
        text:
            '${prediction.label} ${(prediction.confidence * 100).toStringAsFixed(1)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: math.max(0, size.width - 16));

      final labelWidth = textPainter.width + 12;
      final labelHeight = textPainter.height + 8;
      final labelTop = math.max(offsetY, rect.top - labelHeight);
      final labelRect = Rect.fromLTWH(
        rect.left,
        labelTop,
        labelWidth,
        labelHeight,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(8)),
        labelPaint,
      );
      textPainter.paint(canvas, Offset(labelRect.left + 6, labelRect.top + 4));
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    return oldDelegate.predictions != predictions ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight ||
        oldDelegate.color != color;
  }
}
