import 'dart:typed_data';

import 'package:flutter/material.dart';

Widget buildSelectedImageCard(
  ThemeData theme, {
  required double cardMaxWidth,
  required double previewMaxHeight,
  required double previewAspectRatio,
  required Uint8List selectedImageBytes,
  required String? selectedImageName,
  required String description,
  required bool isProcessing,
  required String idleActionLabel,
  required String processingActionLabel,
  required VoidCallback? onActionPressed,
  BoxFit imageFit = BoxFit.cover,
}) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: cardMaxWidth),
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
                constraints: BoxConstraints(maxHeight: previewMaxHeight),
                child: AspectRatio(
                  aspectRatio: previewAspectRatio,
                  child: Image.memory(selectedImageBytes, fit: imageFit),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              selectedImageName ?? 'รูปภาพที่อัปโหลด',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
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
                  onPressed: onActionPressed,
                  label: Text(
                    isProcessing ? processingActionLabel : idleActionLabel,
                  ),
                  icon: isProcessing
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
