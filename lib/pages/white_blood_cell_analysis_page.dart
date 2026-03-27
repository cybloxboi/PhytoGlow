import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:phyto_glow/functions/files/pick_image_bytes.dart';
import 'package:phyto_glow/functions/ui/app_bar.dart';
import 'package:phyto_glow/pages/result_page.dart';
import 'package:phyto_glow/services/roboflow_service.dart';

class WhiteBloodCellAnalysisPage extends StatefulWidget {
  const WhiteBloodCellAnalysisPage({super.key});

  @override
  State<WhiteBloodCellAnalysisPage> createState() =>
      _WhiteBloodCellAnalysisPageState();
}

class _WhiteBloodCellAnalysisPageState
    extends State<WhiteBloodCellAnalysisPage> {
  static const double _pageMaxWidth = 560;
  static const double _previewMaxHeight = 320;
  static const double _previewAspectRatio = 4 / 3;
  static const double _cardHorizontalPadding = 16;
  static const double _cardMaxWidth =
      (_previewMaxHeight * _previewAspectRatio) + (_cardHorizontalPadding * 2);

  final RoboflowService _roboflowService = RoboflowService();

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
        throw const _ImageSelectionException(
          'ไม่พบข้อมูลรูปภาพจากไฟล์ที่เลือก กรุณาลองเลือกรูปใหม่',
        );
      }

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = pickedImage.name;
      });
    } on _ImageSelectionException catch (error) {
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

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResultPage(
            imageBytes: imageBytes,
            imageName: _selectedImageName ?? 'รูปภาพที่อัปโหลด',
            result: result,
          ),
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

    return Scaffold(
      appBar: getAppBar('White Blood Cell Analysis'),
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
                          ? _buildEmptyState(theme)
                          : _buildSelectedImageCard(theme),
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

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
        child: Container(
          key: const ValueKey<String>('empty-state'),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Icon(
                Icons.image_outlined,
                size: 52,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'ยังไม่มีรูปภาพที่เลือก',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'กดปุ่มอัปโหลดด้านบนเพื่อเลือกรูปจากอุปกรณ์ของคุณ',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImageCard(ThemeData theme) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
        child: Container(
          key: const ValueKey('selected-image'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: _previewMaxHeight,
                  ),
                  child: AspectRatio(
                    aspectRatio: _previewAspectRatio,
                    child: Image.memory(
                      _selectedImageBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _selectedImageName ?? 'รูปภาพที่อัปโหลด',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'พร้อมส่งไปวิเคราะห์ด้วยโมเดล Roboflow',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _isAnalyzing ? null : _analyzeImage,
                    label: Text(
                      _isAnalyzing ? 'กำลังวิเคราะห์...' : 'เริ่มวิเคราะห์',
                    ),
                    icon: _isAnalyzing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.navigate_next_rounded),
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

class _ImageSelectionException implements Exception {
  const _ImageSelectionException(this.message);

  final String message;
}
