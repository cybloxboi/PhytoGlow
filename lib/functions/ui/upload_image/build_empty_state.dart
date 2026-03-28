import 'package:flutter/material.dart';

Widget buildEmptyState(
  ThemeData theme,
  double cardMaxWidth, {
  String? title,
  String? description,
}) {
  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: cardMaxWidth),
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
              title ?? 'ยังไม่มีรูปภาพที่เลือก',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description ?? 'กดปุ่มอัปโหลดด้านบนเพื่อเลือกรูปจากอุปกรณ์ของคุณ',
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
