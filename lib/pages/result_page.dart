import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:phyto_glow/classes/roboflow_inference_result.dart';
import 'package:phyto_glow/classes/roboflow_prediction.dart';
import 'package:phyto_glow/functions/ui/app_bar.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({
    super.key,
    required this.imageBytes,
    required this.imageName,
    required this.result,
  });

  final Uint8List imageBytes;
  final String imageName;
  final RoboflowInferenceResult result;
  static const double _pageMaxWidth = 700;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wbcPredictions = result.predictions.where(_isWbcPrediction).toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    final wbcClassCounts = <String, int>{};
    for (final prediction in wbcPredictions) {
      wbcClassCounts.update(
        prediction.label,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    final topPrediction = wbcPredictions.isEmpty ? null : wbcPredictions.first;
    final imageWidth = result.imageWidth?.toDouble();
    final imageHeight = result.imageHeight?.toDouble();
    final aspectRatio =
        imageWidth != null &&
            imageHeight != null &&
            imageWidth > 0 &&
            imageHeight > 0
        ? imageWidth / imageHeight
        : 4 / 3;

    return Scaffold(
      appBar: getAppBar('ผลการวิเคราะห์'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _pageMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 50,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Text(
                                    'วิเคราะห์เสร็จสิ้น',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'White Blood Cell Analysis',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.72),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 320,
                                ),
                                child: AspectRatio(
                                  aspectRatio: aspectRatio,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.memory(
                                        imageBytes,
                                        fit: BoxFit.contain,
                                      ),
                                      Positioned.fill(
                                        child: CustomPaint(
                                          painter: _BoundingBoxPainter(
                                            predictions: wbcPredictions,
                                            imageWidth: imageWidth,
                                            imageHeight: imageHeight,
                                            color: theme.colorScheme.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            imageName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            wbcPredictions.isEmpty
                                ? 'ไม่พบ เม็ดเลือดขาว จากผลลัพธ์ Roboflow'
                                : 'แสดงกรอบเฉพาะวัตถุที่เป็น เม็ดเลือดขาว จาก Roboflow',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ภาพรวมผลลัพธ์เม็ดเลือดขาวที่พบ',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _MetricTile(
                                  label: 'จำนวนเม็ดเลือดขาวที่ตรวจพบ',
                                  value: '${wbcPredictions.length}',
                                ),
                                _MetricTile(
                                  label: 'ความมั่นใจสูงสุด',
                                  value: topPrediction == null
                                      ? '-'
                                      : '${(topPrediction.confidence * 100).toStringAsFixed(1)}%',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'รายละเอียดเม็ดเลือดขาว',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (wbcPredictions.isEmpty)
                            Text(
                              'ไม่มี prediction ที่ผ่านเงื่อนไข เม็ดเลือดขาว',
                              style: theme.textTheme.bodyMedium,
                            )
                          else
                            ...wbcPredictions.map(
                              (prediction) =>
                                  _PredictionTile(prediction: prediction),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isWbcPrediction(RoboflowPrediction prediction) {
    final normalized = prediction.label.trim().toLowerCase();
    return normalized == 'wbc' ||
        normalized.contains('wbc') ||
        normalized.contains('white blood cell') ||
        normalized.contains('white_blood_cell') ||
        normalized.contains('white-blood-cell') ||
        normalized.contains('leukocyte');
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionTile extends StatelessWidget {
  const _PredictionTile({required this.prediction});

  final RoboflowPrediction prediction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prediction.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(prediction.confidence * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'x: ${_formatDouble(prediction.x)}  y: ${_formatDouble(prediction.y)}  w: ${_formatDouble(prediction.width)}  h: ${_formatDouble(prediction.height)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDouble(double? value) {
    if (value == null) return '-';
    return value.toStringAsFixed(1);
  }
}

class _BoundingBoxPainter extends CustomPainter {
  const _BoundingBoxPainter({
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
  bool shouldRepaint(covariant _BoundingBoxPainter oldDelegate) {
    return oldDelegate.predictions != predictions ||
        oldDelegate.imageWidth != imageWidth ||
        oldDelegate.imageHeight != imageHeight ||
        oldDelegate.color != color;
  }
}
