import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:phyto_glow/functions/image_processing/get_roi.dart';
import 'package:phyto_glow/functions/image_processing/process_luminol.dart';
import 'package:phyto_glow/functions/colors/yuv420_to_image.dart';
import 'package:phyto_glow/main.dart';
import 'package:image/image.dart' as img;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  Uint8List? thresholdedBytes;
  double meanValue = 0.0;
  int frameCount = 0;
  List<double> intensityHistory = [];

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _controller.initialize().then((_) {
      _controller.startImageStream(processImage);
      setState(() {});
    });
  }

  void processImage(CameraImage image) async {
    frameCount++;

    if (frameCount % 5 != 0) return;

    final bytes = yuv420ToImage(image);
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return;

    int rotation = cameras.first.sensorOrientation;

    final rotated = img.copyRotate(decoded, angle: rotation.toDouble());
    final roi = getROI(rotated);
    final result = processLuminol(roi);

    setState(() {
      thresholdedBytes = Uint8List.fromList(
        img.encodeJpg(result.thresholdedImage),
      );
      meanValue = result.intensityPercent;

      intensityHistory.add(meanValue);

      if (intensityHistory.length > 50) {
        intensityHistory.removeAt(0);
      }
    });
  }

  Widget buildChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Text('${value.toInt()}%');
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                intensityHistory.length,
                (i) => FlSpot(i.toDouble(), intensityHistory[i]),
              ),
              isCurved: true,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Phyto Glow")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
            const SizedBox(height: 10),
            thresholdedBytes != null
                ? Image.memory(thresholdedBytes!, height: 200)
                : const Text("ไม่พบภาพ"),
            const SizedBox(height: 10),
            Text(
              "ความสามารถในการเรืองแสง: ${meanValue.toStringAsFixed(3)}%",
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 10),
            buildChart(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
