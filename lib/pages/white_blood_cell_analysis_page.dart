import 'package:flutter/material.dart';
import 'package:phyto_glow/functions/ui/app_bar.dart';

class WhiteBloodCellAnalysisPage extends StatefulWidget {
  const WhiteBloodCellAnalysisPage({super.key});

  @override
  State<WhiteBloodCellAnalysisPage> createState() =>
      _WhiteBloodCellAnalysisPageState();
}

class _WhiteBloodCellAnalysisPageState
    extends State<WhiteBloodCellAnalysisPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: getAppBar('White Blood Cell Analysis'));
  }
}
