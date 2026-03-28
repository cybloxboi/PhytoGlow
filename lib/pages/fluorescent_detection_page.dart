import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phyto_glow/classes/data/result_page_data.dart';
import 'package:phyto_glow/functions/ui/app_bar.dart';

import '../classes/exception/image_selection_exception.dart';
import '../classes/ui/help_item.dart';
import '../classes/ui/show_upload_help_bottom_sheet.dart';
import '../functions/files/pick_image_bytes.dart';
import '../functions/image_processing/analyze_fluorescent.dart';
import '../functions/ui/upload_image/build_empty_state.dart';
import '../functions/ui/upload_image/build_selected_image_card.dart';

class FluorescentDetectionPage extends StatefulWidget {
  const FluorescentDetectionPage({super.key});

  @override
  State<FluorescentDetectionPage> createState() =>
      _FluorescentDetectionPageState();
}

class _FluorescentDetectionPageState extends State<FluorescentDetectionPage> {
  static const double _pageMaxWidth = 700;
  static const double _previewMaxHeight = 320;
  static const double _previewAspectRatio = 4 / 3;
  static const double _cardHorizontalPadding = 16;
  static const double _cardMaxWidth =
      (_previewMaxHeight * _previewAspectRatio) + (_cardHorizontalPadding * 2);

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isPickingImage = false;
  bool _isAnalyzing = false;

  final helpItems = [
    HelpItem(
      icon: Icons.lightbulb,
      title: 'ใช้แสงกระตุ้นที่เหมาะสม',
      description:
          'ใช้แหล่งกำเนิดแสง (เช่น UV หรือแสงเฉพาะช่วงคลื่น) ที่เหมาะกับตัวอย่าง เพื่อให้เกิด fluorescence ได้ชัด',
    ),
    HelpItem(
      icon: Icons.center_focus_strong,
      title: 'จัดโฟกัสให้คมชัด',
      description:
          'ตรวจสอบให้ภาพไม่เบลอ และโฟกัสอยู่ที่บริเวณตัวอย่าง เพื่อความแม่นยำในการวิเคราะห์',
    ),
    HelpItem(
      icon: Icons.straighten,
      title: 'รักษาระยะห่างคงที่',
      description:
          'ควรถ่ายในระยะห่างที่สม่ำเสมอทุกครั้ง เพื่อให้สามารถเปรียบเทียบความเข้มได้อย่างถูกต้อง',
    ),
    HelpItem(
      icon: Icons.tune,
      title: 'ตั้งค่า White Balance ให้เหมาะสม',
      description:
          'หลีกเลี่ยงการใช้ auto white balance หากทำให้สีเพี้ยน ควรตั้งค่าให้คงที่',
    ),
    HelpItem(
      icon: Icons.crop,
      title: 'หลีกเลี่ยงสิ่งรบกวนในภาพ',
      description:
          'พยายามให้มีเฉพาะตัวอย่างในภาพ และหลีกเลี่ยงพื้นหลังหรือวัตถุอื่นที่อาจรบกวนการวิเคราะห์',
    ),
    HelpItem(
      icon: Icons.flash_off,
      title: 'ปิดแฟลช',
      description: 'ไม่ควรใช้แฟลชจากกล้อง เนื่องจากจะรบกวนสัญญาณ fluorescence',
    ),
  ];

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

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _analyzeImage() async {
    final imageBytes = _selectedImageBytes;

    if (_isAnalyzing || imageBytes == null) {
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await analyzeFluorescent(imageBytes);

      if (!mounted) {
        return;
      }

      context.goNamed(
        'fluorescent-result',
        extra: ResultPageData.fluorescent(
          imageBytes: imageBytes,
          imageName: _selectedImageName ?? 'รูปภาพที่อัปโหลด',
          result: result,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError('ไม่สามารถวิเคราะห์ภาพ Fluorescent ได้\n$error');
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
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
          'Fluorescent Detection',
          actions: [
            IconButton(
              onPressed: () {
                showUploadHelpBottomSheet(
                  context,
                  description:
                      'ในอัปโหลดภาพตัวอย่างสำหรับการวิเคราะห์ Fluorescent Detection ควรถ่ายภาพภายใต้สภาวะที่เหมาะสม เพื่อลดสัญญาณรบกวนและเพิ่มความแม่นยำของผลลัพธ์',
                  helpItems: helpItems,
                  exampleImageUrl:
                      'https://www.scimath.org/images/uploads/upload2/luminol2.jpg',
                  exampleImageDescription: 'ขอบคุณภาพจาก SciMath',
                );
              },
              icon: Icon(Icons.help_outline_rounded),
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
                        'อัปโหลดภาพเพื่อตรวจสอบและเตรียมตรวจจับปฏิกิริยา Fluorescent',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'เมื่อกดเริ่มวิเคราะห์ ระบบจะส่งรูปภาพนี้ไปยัง OpenCV แล้วเปิดหน้าผลลัพธ์ให้อัตโนมัติ',
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
                          onPressed: _isPickingImage ? null : _pickImage,
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
                                    'พร้อมวิเคราะห์ความเข้มของสัญญาณ Fluorescent ด้วย OpenCV',
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
