import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phyto_glow/functions/ui/app_bar.dart';

import '../classes/exception/image_selection_exception.dart';
import '../functions/files/pick_image_bytes.dart';
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
  final bool _isAnalyzing = false;

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

  void _showAnalyzeUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('การวิเคราะห์ภาพแบบอัปโหลดยังไม่พร้อมใช้งานในหน้านี้'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Title(
      title: 'Phyto Glow',
      color: const Color(0xFF3F51B5),
      child: Scaffold(
        appBar: getAppBar(context, 'Fluorescent Detection'),
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
                                    'เลือกรูปภาพแล้ว และพร้อมสำหรับวิเคราะห์ Fluorescent เมื่อเปิดใช้งาน',
                                isProcessing: _isAnalyzing,
                                idleActionLabel: 'เริ่มวิเคราะห์',
                                processingActionLabel: 'กำลังวิเคราะห์...',
                                onActionPressed: _showAnalyzeUnavailable,
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
