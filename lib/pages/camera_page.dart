import 'package:camera/camera.dart';
import 'package:opencv_dart/opencv.dart' as cv;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phyto_glow/functions/image_processing/get_roi.dart';
import 'package:phyto_glow/functions/image_processing/process_luminol.dart';
import 'package:phyto_glow/main.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  Uint8List? thresholdedBytes;
  double meanValue = 0.0;
  bool isProcessing = false;
  List<double> intensityHistory = [];

  @override
  void initState() {
    super.initState();

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

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
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

      if (!mounted) return;
      setState(() {
        thresholdedBytes = result.thresholdedBytes;
        meanValue = result.intensityPercent;

        intensityHistory.add(meanValue);
        if (intensityHistory.length > 50) {
          intensityHistory.removeAt(0);
        }
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
    if (thresholdedBytes == null) {
      return const Text('ยังไม่มีผลวิเคราะห์');
    }

    return Column(
      children: [
        Image.memory(thresholdedBytes!, height: 200),
        const SizedBox(height: 10),
        Text(
          'ความสามารถในการเรืองแสง: ${meanValue.toStringAsFixed(3)}%',
          style: const TextStyle(fontSize: 22),
        ),
      ],
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
