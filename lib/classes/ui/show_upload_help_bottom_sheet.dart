import 'package:flutter/material.dart';
import 'package:phyto_glow/classes/ui/help_item.dart';

Future<void> showUploadHelpBottomSheet(
  BuildContext context, {
  String title = 'คำแนะนำในการอัปโหลดภาพ',
  required String description,
  required List<HelpItem> helpItems,
  required String exampleImageUrl,
  required String exampleImageDescription,
}) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (bottomSheetContext) {
      final theme = Theme.of(bottomSheetContext);

      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.85,
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.78,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(helpItems.length, (index) {
                          final item = helpItems[index];

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == helpItems.length - 1 ? 0 : 16,
                            ),
                            child: item,
                          );
                        }),
                        const SizedBox(height: 20),
                        Text(
                          'ตัวอย่างภาพ',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 320,
                              maxHeight: 180,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.network(
                                  exampleImageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(child: Text(exampleImageDescription)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(bottomSheetContext).pop(),
                        child: const Text('เข้าใจแล้ว'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
