import 'package:flutter/material.dart';
import 'package:phyto_glow/classes/models/detection_item.dart';
import 'package:phyto_glow/classes/models/detection_result.dart';
import 'package:phyto_glow/classes/ui/detection_card.dart';
import 'package:phyto_glow/classes/ui/result_horizontal_list.dart';
import 'package:phyto_glow/functions/ui/app_bar.dart';
import 'package:phyto_glow/pages/fluorescent_detection_page.dart';
import 'package:phyto_glow/pages/white_blood_cell_analysis_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static const double _pageMaxWidth = 960;

  late final AnimationController _staggerController;

  final List<DetectionItem> detectionItems = [
    DetectionItem(
      title: 'Fluorescent Detection',
      description: 'Description',
      buttonText: 'Start Detection',
      icon: Icons.wb_sunny_outlined,
    ),
    DetectionItem(
      title: 'White Blood Cell Analysis',
      description: 'Description',
      buttonText: 'Start Analysis',
      icon: Icons.science_outlined,
    ),
  ];

  final List<DetectionResult> resultItems = [
    DetectionResult(
      title: 'Just some name bruh',
      type: 'Fluorescent Detection',
      confidence: 0.94,
      date: DateTime.now(),
    ),
    DetectionResult(
      title: 'โอ้ม้าย เฮ็ดได้ยังไง',
      type: 'WBC Analysis',
      confidence: 0.78,
      date: DateTime(2023, 10, 20),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _buildCardAnimation(int index) {
    final start = (index * 0.1).clamp(0.0, 0.8);
    final end = (start + 0.45).clamp(0.0, 1.0);

    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  void _handleResultTap(DetectionResult item) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('เปิดผลวิเคราะห์: ${item.title}')));
  }

  void _openDetectionPage(DetectionItem item) {
    Widget page;

    switch (item.title) {
      case 'Fluorescent Detection':
        page = const FluorescentDetectionPage();
      case 'White Blood Cell Analysis':
        page = const WhiteBloodCellAnalysisPage();
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ยังไม่มีหน้าสำหรับ ${item.title}')),
        );
        return;
    }

    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar('Phyto Glow'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _pageMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!\nยินดีต้อนรับกลับ',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(detectionItems.length, (index) {
                      final item = detectionItems[index];

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == detectionItems.length - 1 ? 0 : 16,
                        ),
                        child: DetectionCard(
                          key: ValueKey(item.title),
                          title: item.title,
                          description: item.description,
                          buttonText: item.buttonText,
                          icon: item.icon,
                          onPressed: () => _openDetectionPage(item),
                          animation: _buildCardAnimation(index),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Recent Analysis\nการวินิจฉัยล่าสุด',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('ดูทั้งหมด'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ResultHorizontalList(
                      items: resultItems,
                      onItemTap: _handleResultTap,
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
}
