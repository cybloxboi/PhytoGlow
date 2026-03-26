import 'package:flutter/material.dart';
import 'package:phyto_glow/functions/ui/app_bar.dart';

class FluorescentDetectionPage extends StatefulWidget {
  const FluorescentDetectionPage({super.key});

  @override
  State<FluorescentDetectionPage> createState() =>
      _FluorescentDetectionPageState();
}

class _FluorescentDetectionPageState extends State<FluorescentDetectionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar('Fluorescent Detection'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam_off_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'ปิดการใช้งานกล้องชั่วคราว',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'หน้านี้ยังไม่ขอสิทธิ์กล้องในตอนนี้ เมื่อพร้อมใช้งานอีกครั้งเราค่อยเปิดกลับได้ทันที',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
