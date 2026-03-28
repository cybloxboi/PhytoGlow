import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phyto_glow/classes/data/result_page_data.dart';
import 'package:phyto_glow/classes/ui/help_item.dart';
import 'package:phyto_glow/functions/files/pick_image_bytes.dart';
import 'package:phyto_glow/functions/ui/app_bar.dart';
import 'package:phyto_glow/functions/ui/upload_image/build_empty_state.dart';
import 'package:phyto_glow/functions/ui/upload_image/build_selected_image_card.dart';
import 'package:phyto_glow/services/roboflow_service.dart';

import '../classes/exception/image_selection_exception.dart';
import '../classes/exception/roboflow_exception.dart';
import '../classes/ui/show_upload_help_bottom_sheet.dart';

class WhiteBloodCellAnalysisPage extends StatefulWidget {
  const WhiteBloodCellAnalysisPage({super.key});

  @override
  State<WhiteBloodCellAnalysisPage> createState() =>
      _WhiteBloodCellAnalysisPageState();
}

class _WhiteBloodCellAnalysisPageState
    extends State<WhiteBloodCellAnalysisPage> {
  static const double _pageMaxWidth = 700;
  static const double _previewMaxHeight = 320;
  static const double _previewAspectRatio = 4 / 3;
  static const double _cardHorizontalPadding = 16;
  static const double _cardMaxWidth =
      (_previewMaxHeight * _previewAspectRatio) + (_cardHorizontalPadding * 2);

  final RoboflowService _roboflowService = RoboflowService();
  final List<HelpItem> helpItems = [
    HelpItem(
      icon: Icons.center_focus_strong_rounded,
      title: 'โฟกัสภาพให้คมชัด',
      description:
          'หลีกเลี่ยงภาพเบลอ สั่น หรือหลุดโฟกัส เพื่อให้โมเดลแยกวัตถุได้ง่ายขึ้น',
    ),
    HelpItem(
      icon: Icons.wb_sunny_outlined,
      title: 'แสงต้องสม่ำเสมอ',
      description:
          'ใช้ภาพที่สว่างพอ ไม่มีเงามืดจัดหรือแสงสะท้อนแรงเกินไปบนสไลด์',
    ),
    HelpItem(
      icon: Icons.crop_free_rounded,
      title: 'ให้บริเวณตัวอย่างอยู่กลางภาพ',
      description:
          'อย่าครอปชิดเกินไป และพยายามให้พื้นที่ที่ต้องการวิเคราะห์อยู่ในเฟรมอย่างครบถ้วน',
    ),
    HelpItem(
      icon: Icons.image_not_supported_outlined,
      title: 'หลีกเลี่ยงภาพที่มีสิ่งรบกวน',
      description:
          'เช่น ตัวหนังสือทับภาพ กราฟิก หรือพื้นหลังที่ไม่เกี่ยวข้องจำนวนมาก',
    ),
  ];

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isPickingImage = false;
  bool _isAnalyzing = false;

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final pickedImage = await pickImageBytes();
      if (pickedImage == null) return;

      final bytes = pickedImage.bytes;
      if (!mounted) return;

      if (bytes.isEmpty) {
        throw const ImageSelectionException(
          'ไม่พบข้อมูลรูปภาพจากไฟล์ที่เลือก กรุณาลองเลือกรูปใหม่',
        );
      }

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = pickedImage.name;
      });
    } on ImageSelectionException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } catch (error) {
      if (!mounted) return;
      _showError('ไม่สามารถเลือกรูปภาพได้ กรุณาลองใหม่อีกครั้ง\n$error');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _analyzeImage() async {
    final imageBytes = _selectedImageBytes;
    if (_isAnalyzing || imageBytes == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await _roboflowService.inferImage(imageBytes);
      if (!mounted) return;

      context.goNamed(
        'wbc-result',
        extra: ResultPageData.wbc(
          imageBytes: imageBytes,
          imageName: _selectedImageName ?? 'รูปภาพที่อัปโหลด',
          result: result,
        ),
      );
    } on RoboflowException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } catch (error) {
      if (!mounted) return;
      _showError('ไม่สามารถวิเคราะห์รูปภาพได้ กรุณาลองใหม่อีกครั้ง\n$error');
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Title(
      title: 'Phyto Glow',
      color: const Color(0xFF3F51B5),
      child: Scaffold(
        appBar: getAppBar(
          context,
          'White Blood Cell Analysis',
          actions: [
            IconButton(
              onPressed: () {
                showUploadHelpBottomSheet(
                  context,
                  description:
                      'เพื่อให้ระบบวิเคราะห์เม็ดเลือดขาวได้แม่นยำขึ้น แนะนำให้เลือกรูปที่มีคุณสมบัติตามนี้',
                  helpItems: helpItems,
                  exampleImagePath: 'assets/images/leukocytes.jpg',
                  exampleImageDescription: 'ขอบคุณภาพจาก Pathology Student',
                );
              },
              icon: const Icon(Icons.help_outline_rounded),
            ),
          ],
        ),
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
                      Text(
                        'อัปโหลดภาพเพื่อตรวจสอบและเตรียมวิเคราะห์เม็ดเลือดขาว',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'เมื่อกดเริ่มวิเคราะห์ ระบบจะส่งรูปภาพนี้ไปยัง Roboflow API แล้วเปิดหน้าผลลัพธ์ให้อัตโนมัติ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.72,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isPickingImage || _isAnalyzing
                              ? null
                              : _pickImage,
                          icon: _isPickingImage
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.upload_rounded),
                          label: Text(
                            _isPickingImage
                                ? 'กำลังเลือกรูปภาพ...'
                                : 'อัปโหลดรูปภาพ',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _selectedImageBytes == null
                            ? buildEmptyState(theme, _cardMaxWidth)
                            : buildSelectedImageCard(
                                theme,
                                cardMaxWidth: _cardMaxWidth,
                                previewMaxHeight: _previewMaxHeight,
                                previewAspectRatio: _previewAspectRatio,
                                selectedImageBytes: _selectedImageBytes!,
                                selectedImageName: _selectedImageName,
                                description:
                                    'พร้อมส่งไปวิเคราะห์ด้วยโมเดล Roboflow',
                                isProcessing: _isAnalyzing,
                                idleActionLabel: 'เริ่มวิเคราะห์',
                                processingActionLabel: 'กำลังวิเคราะห์...',
                                onActionPressed: _isAnalyzing
                                    ? null
                                    : _analyzeImage,
                                imageFit: BoxFit.cover,
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
}
