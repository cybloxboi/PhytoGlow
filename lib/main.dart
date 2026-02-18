import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:phyto_glow/pages/camera_page.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const PhytoGlow());
}

class PhytoGlow extends StatelessWidget {
  const PhytoGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: CameraPage());
  }
}
