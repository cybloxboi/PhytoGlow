import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:phyto_glow/classes/data/result_page_data.dart';
import 'package:phyto_glow/classes/models/luminol_result.dart';
import 'package:phyto_glow/classes/roboflow/roboflow_prediction.dart';
import 'package:phyto_glow/functions/files/download_bytes.dart';
import 'package:phyto_glow/functions/ui/app_bar.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.data});

  final ResultPageData data;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  static const double _pageMaxWidth = 700;

  final GlobalKey _imageExportKey = GlobalKey();
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resultType = widget.data.analysisType;
    final wbcResult = widget.data.wbcResult;
    final fluorescentResult = widget.data.fluorescentResult;
    final wbcPredictions =
        (wbcResult?.predictions ?? const <RoboflowPrediction>[])
            .where(_isWbcPrediction)
            .toList()
          ..sort((a, b) => b.confidence.compareTo(a.confidence));
    final topPrediction = wbcPredictions.isEmpty ? null : wbcPredictions.first;
    final imageWidth = wbcResult?.imageWidth?.toDouble();
    final imageHeight = wbcResult?.imageHeight?.toDouble();
    final aspectRatio =
        resultType == ResultAnalysisType.wbc &&
            imageWidth != null &&
            imageHeight != null &&
            imageWidth > 0 &&
            imageHeight > 0
        ? imageWidth / imageHeight
        : 4 / 3;

    return Title(
      title: 'Phyto Glow',
      color: const Color(0xFF3F51B5),
      child: Scaffold(
        appBar: getAppBar(context, 'ผลการวิเคราะห์'),
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
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 50,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'วิเคราะห์เสร็จสิ้น',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _buildAnalysisLabel(resultType),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.72),
                                  ),
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
                              child: RepaintBoundary(
                                key: _imageExportKey,
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
                                            _displayImageBytes,
                                            fit: BoxFit.contain,
                                          ),
                                          if (resultType ==
                                              ResultAnalysisType.wbc)
                                            Positioned.fill(
                                              child: CustomPaint(
                                                painter: _BoundingBoxPainter(
                                                  predictions: wbcPredictions,
                                                  imageWidth: imageWidth,
                                                  imageHeight: imageHeight,
                                                  color: theme
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.data.imageName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _buildImageDescription(
                                resultType,
                                wbcPredictions,
                                fluorescentResult,
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.72,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: _isDownloading
                                    ? null
                                    : _downloadAnnotatedImage,
                                icon: _isDownloading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.download_rounded),
                                label: Text(
                                  _isDownloading
                                      ? 'กำลังเตรียมไฟล์...'
                                      : 'ดาวน์โหลดภาพผลลัพธ์',
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
                                _buildMetricSectionTitle(resultType),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children:
                                    resultType == ResultAnalysisType.fluorescent
                                    ? _buildFluorescentMetricTiles(
                                        fluorescentResult,
                                      )
                                    : _buildWbcMetricTiles(
                                        wbcPredictions.length,
                                        topPrediction,
                                      ),
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
                              _buildDetailSectionTitle(resultType),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (resultType == ResultAnalysisType.fluorescent)
                              ..._buildFluorescentDetails(
                                context,
                                fluorescentResult,
                              )
                            else if (wbcPredictions.isEmpty)
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
      ),
    );
  }

  Future<void> _downloadAnnotatedImage() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final boundary =
          _imageExportKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('ไม่พบภาพสำหรับดาวน์โหลด');
      }

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      final bytes = byteData?.buffer.asUint8List();
      if (bytes == null || bytes.isEmpty) {
        throw StateError('ไม่สามารถสร้างไฟล์ภาพได้');
      }

      await downloadBytes(
        bytes: bytes,
        fileName: _buildDownloadFileName(widget.data),
        mimeType: 'image/png',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ดาวน์โหลดภาพผลลัพธ์แล้ว')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ดาวน์โหลดภาพไม่สำเร็จ\n$error')));
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  String _buildDownloadFileName(ResultPageData data) {
    final sourceName = data.imageName;
    final normalized = sourceName
        .replaceAll(RegExp(r'\.[^.]+$'), '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    final baseName = normalized.isEmpty
        ? data.isFluorescent
              ? 'fluorescent_result'
              : 'wbc_result'
        : normalized;
    final suffix = data.isFluorescent ? 'fluorescent_result' : 'wbc_result';
    return '${baseName}_$suffix.png';
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

  List<Widget> _buildWbcMetricTiles(
    int wbcCount,
    RoboflowPrediction? topPrediction,
  ) {
    return [
      _MetricTile(label: 'จำนวนเม็ดเลือดขาวที่ตรวจพบ', value: '$wbcCount'),
      _MetricTile(
        label: 'ความมั่นใจสูงสุด',
        value: topPrediction == null
            ? '-'
            : '${(topPrediction.confidence * 100).toStringAsFixed(1)}%',
      ),
    ];
  }

  List<Widget> _buildFluorescentMetricTiles(LuminolResult? result) {
    final intensity = result?.intensityPercent ?? 0;
    return [
      _MetricTile(
        label: 'พื้นที่เรืองแสงที่ตรวจพบ',
        value: '${result?.area ?? 0} px',
      ),
      _MetricTile(
        label: 'ค่าความเข้มเฉลี่ย',
        value: (result?.meanIntensity ?? 0).toStringAsFixed(1),
      ),
      _MetricTile(
        label: 'ค่าความเข้มสูงสุด',
        value: '${result?.maxIntensity ?? 0}',
      ),
      _MetricTile(
        label: 'ความเข้มเฉลี่ยโดยประมาณ',
        value: '${intensity.toStringAsFixed(2)}%',
      ),
    ];
  }

  List<Widget> _buildFluorescentDetails(
    BuildContext context,
    LuminolResult? result,
  ) {
    final theme = Theme.of(context);
    final intensity = result?.intensityPercent ?? 0;
    return [
      Text(
        _fluorescentSummary(intensity),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 6),
      const Divider(),
      const SizedBox(height: 6),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.help_outline_rounded, color: theme.colorScheme.secondary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'ภาพผลลัพธ์ด้านบนคือ preview overlay จาก FastAPI โดยระบบจะ highlight บริเวณที่ตรวจผ่าน mask เป็นสีเขียว',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'ข้อมูลนี้ใช้สำหรับการเปรียบเทียบความเข้มในเบื้องต้นเท่านั้น ไม่สามารถใช้ทดแทนเครื่องมือทางวิทยาศาสตร์ได้ ควรให้ผู้เชี่ยวชาญเป็นผู้ประเมิน และพิจารณาร่วมกับปัจจัยในการถ่ายภาพ เช่น แสง การตั้งค่า white balance และระยะห่างจากตัวอย่าง',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  String _buildAnalysisLabel(ResultAnalysisType type) {
    switch (type) {
      case ResultAnalysisType.fluorescent:
        return 'Fluorescent Detection';
      case ResultAnalysisType.wbc:
        return 'White Blood Cell Analysis';
    }
  }

  String _buildMetricSectionTitle(ResultAnalysisType type) {
    switch (type) {
      case ResultAnalysisType.fluorescent:
        return 'ภาพรวมผลการตรวจจับสัญญาณ Fluorescent';
      case ResultAnalysisType.wbc:
        return 'ภาพรวมผลลัพธ์เม็ดเลือดขาวที่พบ';
    }
  }

  String _buildDetailSectionTitle(ResultAnalysisType type) {
    switch (type) {
      case ResultAnalysisType.fluorescent:
        return 'รายละเอียดการวิเคราะห์ Fluorescent';
      case ResultAnalysisType.wbc:
        return 'รายละเอียดเม็ดเลือดขาว';
    }
  }

  String _buildImageDescription(
    ResultAnalysisType type,
    List<RoboflowPrediction> wbcPredictions,
    LuminolResult? fluorescentResult,
  ) {
    switch (type) {
      case ResultAnalysisType.fluorescent:
        final intensity = fluorescentResult?.intensityPercent ?? 0;
        final area = fluorescentResult?.area ?? 0;
        return 'แสดงภาพ overlay จาก FastAPI พร้อมบริเวณเรืองแสงที่ตรวจพบ พื้นที่ $area px และความเข้มเฉลี่ย ${intensity.toStringAsFixed(2)}%';
      case ResultAnalysisType.wbc:
        return wbcPredictions.isEmpty
            ? 'ไม่พบเม็ดเลือดขาว จากผลลัพธ์ Roboflow'
            : 'แสดงกรอบเฉพาะวัตถุที่เป็นเม็ดเลือดขาว จาก Roboflow';
    }
  }

  String _fluorescentSummary(double intensity) {
    if (intensity >= 75) {
      return 'ตรวจพบสัญญาณ Fluorescent ค่อนข้างสูงจากค่าเฉลี่ยความเข้มในบริเวณที่ระบบทำ mask';
    }

    if (intensity >= 40) {
      return 'ตรวจพบสัญญาณ Fluorescent ระดับปานกลาง ควรพิจารณาภาพต้นฉบับและสภาพแสงร่วมด้วย';
    }

    if (intensity > 0) {
      return 'ตรวจพบสัญญาณ Fluorescent ระดับต่ำหรือบางส่วน อาจได้รับผลจากแสงและสภาพพื้นหลัง';
    }

    return 'ยังไม่พบบริเวณ Fluorescent ที่ผ่านเกณฑ์ threshold ของ API';
  }

  Uint8List get _displayImageBytes {
    if (widget.data.isFluorescent) {
      return widget.data.fluorescentResult?.thresholdedBytes ??
          widget.data.imageBytes;
    }

    return widget.data.imageBytes;
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
