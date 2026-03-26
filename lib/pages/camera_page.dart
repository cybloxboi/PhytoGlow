import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencv_dart/opencv.dart' as cv;
import 'package:phyto_glow/classes/roboflow_inference_result.dart';
import 'package:phyto_glow/functions/image_processing/get_roi.dart';
import 'package:phyto_glow/functions/image_processing/process_luminol.dart';
import 'package:phyto_glow/services/roboflow_service.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  final RoboflowService _roboflowService = RoboflowService();
  Uint8List? thresholdedBytes;
  double meanValue = 0.0;
  bool isProcessing = false;
  RoboflowInferenceResult? roboflowResult;
  String? roboflowError;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> captureAndProcessImage() async {
    if (!_controller.value.isInitialized || isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    cv.Mat? src;
    cv.Mat? roi;

    try {
      final xfile = await _controller.takePicture();
      final bytes = await xfile.readAsBytes();
      src = cv.imdecode(bytes, cv.IMREAD_COLOR);

      if (src.isEmpty) return;

      roi = getROI(src);
      final result = processLuminol(roi);
      RoboflowInferenceResult? inferenceResult;
      String? inferenceError;

      try {
        inferenceResult = await _roboflowService.inferImage(bytes);
      } on RoboflowException catch (e) {
        inferenceError = e.message;
      }

      if (!mounted) return;
      setState(() {
        thresholdedBytes = result.thresholdedBytes;
        meanValue = result.intensityPercent;
        roboflowResult = inferenceResult;
        roboflowError = inferenceError;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ถ่ายภาพไม่สำเร็จ: ${e.description ?? e.code}')),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ประมวลผลภาพไม่สำเร็จ: ${e.message ?? e.code}')),
      );
    } finally {
      src?.dispose();
      roi?.dispose();

      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Widget buildCaptureButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton.icon(
        onPressed: isProcessing ? null : captureAndProcessImage,
        icon: isProcessing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.camera_alt),
        label: Text(isProcessing ? 'กำลังประมวลผล...' : 'ถ่ายรูปและวิเคราะห์'),
      ),
    );
  }

  Widget buildResultSection() {
    if (thresholdedBytes == null && roboflowResult == null && roboflowError == null) {
      return const Text('ยังไม่มีผลวิเคราะห์');
    }

    return Column(
      children: [
        if (thresholdedBytes != null) Image.memory(thresholdedBytes!, height: 200),
        const SizedBox(height: 10),
        Text(
          'ความสามารถในการเรืองแสง: ${meanValue.toStringAsFixed(3)}%',
          style: const TextStyle(fontSize: 22),
        ),
        const SizedBox(height: 16),
        buildRoboflowSection(),
      ],
    );
  }

  Widget buildRoboflowSection() {
    if (roboflowError != null) {
      return Text(
        'Roboflow error: $roboflowError',
        style: const TextStyle(color: Colors.red),
      );
    }

    final result = roboflowResult;
    if (result == null) {
      return const SizedBox.shrink();
    }

    final summary = result.classCounts.entries.map((entry) {
      return '${entry.key}: ${entry.value}';
    }).join(', ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Roboflow Inference',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Detections: ${result.predictions.length}'),
            if (summary.isNotEmpty) Text('Classes: $summary'),
            if (result.topLabel != null)
              Text(
                'Top: ${result.topLabel} (${((result.topConfidence ?? 0) * 100).toStringAsFixed(1)}%)',
              ),
            const SizedBox(height: 8),
            ...result.predictions.take(5).map((prediction) {
              return Text(
                '${prediction.label} ${(prediction.confidence * 100).toStringAsFixed(1)}%',
              );
            }),
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
      appBar: AppBar(title: const Text('Phyto Glow')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: CameraPreview(_controller),
            ),
            buildCaptureButton(),
            const SizedBox(height: 10),
            buildResultSection(),
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
