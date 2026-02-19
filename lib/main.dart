import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phyto_glow/pages/camera_page.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  cameras = await availableCameras();
  runApp(const PhytoGlow());
}

class PhytoGlow extends StatelessWidget {
  const PhytoGlow({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LayoutBuilder(
        builder: (context, constraints) {
          if (kIsWeb && constraints.maxWidth > 600) {
            return const Scaffold(
              body: Center(
                child: Text(
                  'กรุณาเปิดบนโทรศัพท์มือถือเท่านั้น',
                  style: TextStyle(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return const CameraPage();
        },
      ),
    );
  }
}
