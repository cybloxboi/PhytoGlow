import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:phyto_glow/functions/apply_color_threshold.dart';
import 'package:phyto_glow/functions/calculate_mean_value_hsv.dart';
import 'package:phyto_glow/functions/get_roi.dart';
import 'package:phyto_glow/functions/yuv420_to_image.dart';
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
    final thresholded = applyColorThreshold(roi);
    final mean = calculateMeanValueHSV(roi);

    setState(() {
      thresholdedBytes = Uint8List.fromList(img.encodeJpg(thresholded));
      meanValue = mean;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Luminol Detection")),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: CameraPreview(_controller),
          ),
          const SizedBox(height: 10),
          thresholdedBytes != null
              ? Image.memory(thresholdedBytes!, height: 200)
              : const Text("No processed image"),
          const SizedBox(height: 10),
          Text(
            "Mean Intensity (V): ${meanValue.toStringAsFixed(3)}",
            style: const TextStyle(fontSize: 22),
          ),
        ],
      ),
    );
  }
}
