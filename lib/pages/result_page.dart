import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:phyto_glow/classes/data/result_page_data.dart';
import 'package:phyto_glow/classes/models/luminol_result.dart';
import 'package:phyto_glow/classes/roboflow/roboflow_prediction.dart';
import 'package:phyto_glow/functions/files/download_bytes.dart';
import 'package:phyto_glow/functions/ui/app_bar.dart';

import '../classes/ui/result/bounding_box_painter.dart';
import '../classes/ui/result/metric_tile.dart';
import '../classes/ui/result/prediction_tile.dart';
import '../classes/ui/result/section_card.dart';

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
                      SectionCard(
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
                      SectionCard(
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
                                    child: Stack(
                                      children: [
                                        Image.memory(
                                          _displayImageBytes,
                                          fit: BoxFit.contain,
                                        ),
                                        if (resultType ==
                                            ResultAnalysisType.wbc)
                                          Positioned.fill(
                                            child: CustomPaint(
                                              painter: BoundingBoxPainter(
                                                predictions: wbcPredictions,
                                                imageWidth: imageWidth,
                                                imageHeight: imageHeight,
                                                color:
                                                    theme.colorScheme.secondary,
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
                        child: SectionCard(
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
                      SectionCard(
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
                                'ไม่มี prediction ที่ผ่านเงื่อนไข เซลล์เม็ดเลือดขาว',
                                style: theme.textTheme.bodyMedium,
                              )
                            else
                              ...wbcPredictions.map(
                                (prediction) =>
                                    PredictionTile(prediction: prediction),
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

    return normalized.contains('wbc');
  }

  List<Widget> _buildWbcMetricTiles(
    int wbcCount,
    RoboflowPrediction? topPrediction,
  ) {
    return [
      MetricTile(label: 'จำนวนเซลล์เม็ดเลือดขาวที่ตรวจพบ', value: '$wbcCount'),
      MetricTile(
        label: 'ความมั่นใจสูงสุด',
        value: topPrediction == null
            ? '-'
            : '${(topPrediction.confidence * 100).toStringAsFixed(1)}%',
      ),
    ];
  }

  List<Widget> _buildFluorescentMetricTiles(LuminolResult? result) {
    final intensity = result?.intensityPercent ?? 0;
    final areaPercent = result?.areaPercent ?? 0;
    final snr = result?.snr ?? 0;
    final meanForeground = result?.areaPercent ?? 0;
    final meanBackground = result?.areaPercent ?? 0;
    final otsuThreshold = result?.otsuThreshold ?? 0;
    final regionCount = result?.regionCount ?? 0;
    final largestAreaPx = result?.largestAreaPx ?? 0;
    double confidence = (snr * 10).clamp(0, 100);
    bool isReliable = snr >= 3;
    bool isLargeArea = areaPercent >= 5;

    return [
      MetricTile(
        label: 'เปอร์เซ็นต์ความเข้ม',
        value: '${intensity.toStringAsFixed(2)}%',
        isPrimary: isReliable && isLargeArea,
      ),
      MetricTile(
        label: 'ความมั่นใจ',
        value: '${confidence.toStringAsFixed(2)}%',
        isPrimary: true,
      ),
      MetricTile(
        label: 'อัตราส่วนสัญญาณต่อสัญญาณรบกวน (SNR)',
        value: snr.toStringAsFixed(2),
        isPrimary: !isReliable,
      ),
      MetricTile(
        label: 'เปอร์เซ็นต์พื้นที่',
        value: '${areaPercent.toStringAsFixed(2)}%',
      ),
      MetricTile(
        label: 'ค่าเฉลี่ยความเข้มของวัตถุ',
        value: meanForeground.toStringAsFixed(2),
        maxValue: '255',
      ),
      MetricTile(
        label: 'ค่าเฉลี่ยความเข้มของพื้นหลัง',
        value: meanBackground.toStringAsFixed(2),
        maxValue: '255',
      ),
      MetricTile(
        label: 'ค่าเกณฑ์ Otsu',
        value: otsuThreshold.toStringAsFixed(2),
      ),
      MetricTile(label: 'จำนวนบริเวณ', value: '$regionCount จุด'),
      MetricTile(
        label: 'พื้นที่บริเวณที่ใหญ่ที่สุด',
        value: '$largestAreaPx px²',
      ),
    ];
  }

  List<Widget> _buildFluorescentDetails(
    BuildContext context,
    LuminolResult? result,
  ) {
    final theme = Theme.of(context);
    final intensity = result?.intensityPercent ?? 0;
    final areaPercent = result?.areaPercent ?? 0;
    final snr = result?.snr ?? 0;

    return [
      Text(
        _fluorescentSummary(intensity: intensity, area: areaPercent, snr: snr),
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
          Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'ข้อมูลนี้ใช้สำหรับการเปรียบเทียบความเข้มในเบื้องต้นเท่านั้น ไม่สามารถใช้ทดแทนเครื่องมือทางวิทยาศาสตร์ได้ ควรให้ผู้เชี่ยวชาญเป็นผู้ประเมิน และพิจารณาร่วมกับปัจจัยในการถ่ายภาพ เช่น แสง การตั้งค่า White Balance และระยะห่างจากตัวอย่าง',
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
        return 'ภาพรวมผลลัพธ์เซลล์เม็ดเลือดขาวที่พบ';
    }
  }

  String _buildDetailSectionTitle(ResultAnalysisType type) {
    switch (type) {
      case ResultAnalysisType.fluorescent:
        return 'รายละเอียดการวิเคราะห์ Fluorescent';
      case ResultAnalysisType.wbc:
        return 'รายละเอียดเซลล์เม็ดเลือดขาว';
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
        return 'แสดงภาพ Overlay สีเขียวในบริเวณเรืองแสงที่ตรวจพบจาก FastAPI - ความเข้มเฉลี่ย ${intensity.toStringAsFixed(2)}%';
      case ResultAnalysisType.wbc:
        return wbcPredictions.isEmpty
            ? 'ไม่พบเซลล์เม็ดเลือดขาว จากผลลัพธ์ Roboflow'
            : 'แสดงกรอบเฉพาะวัตถุที่เป็นเซลล์เม็ดเลือดขาว จาก Roboflow';
    }
  }

  String _fluorescentSummary({
    required double intensity,
    required double area,
    required double snr,
  }) {
    // ❌ ไม่มี signal จริง
    if (intensity <= 0 || area <= 0) {
      return 'ยังไม่พบบริเวณ Fluorescent ที่ชัดเจนจากการประมวลผล';
    }

    // 🔴 สัญญาณสูง + น่าเชื่อถือ
    if (intensity >= 70 && snr >= 5 && area >= 5) {
      return 'ตรวจพบสัญญาณ Fluorescent ในระดับสูงและมีความน่าเชื่อถือ โดยมีทั้งความเข้มและพื้นที่ชัดเจน';
    }

    // 🟠 สัญญาณปานกลาง
    if (intensity >= 40 && snr >= 2) {
      return 'ตรวจพบสัญญาณ Fluorescent ระดับปานกลาง ควรพิจารณาภาพต้นฉบับและสภาพแสงเพิ่มเติม';
    }

    // 🟡 สัญญาณต่ำ
    if (intensity > 0) {
      if (snr < 2) {
        return 'ตรวจพบสัญญาณ Fluorescent เล็กน้อย แต่มีความไม่แน่นอนสูง อาจเกิดจาก noise หรือพื้นหลัง';
      }

      if (area < 2) {
        return 'ตรวจพบสัญญาณ Fluorescent ในบางจุด แต่มีพื้นที่น้อย อาจเป็นจุดรบกวนหรือ artifact';
      }

      return 'ตรวจพบสัญญาณ Fluorescent ระดับต่ำ ควรตรวจสอบเพิ่มเติม';
    }

    return 'ไม่สามารถสรุปผลได้';
  }

  Uint8List get _displayImageBytes {
    if (widget.data.isFluorescent) {
      return widget.data.fluorescentResult?.previewBytes ??
          widget.data.imageBytes;
    }

    return widget.data.imageBytes;
  }
}
