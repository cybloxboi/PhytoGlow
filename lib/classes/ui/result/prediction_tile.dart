import 'package:flutter/material.dart';

import '../../roboflow/roboflow_prediction.dart';

class PredictionTile extends StatelessWidget {
  const PredictionTile({super.key, required this.prediction});

  final RoboflowPrediction prediction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prediction.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(prediction.confidence * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'x: ${_formatDouble(prediction.x)}  y: ${_formatDouble(prediction.y)}  w: ${_formatDouble(prediction.width)}  h: ${_formatDouble(prediction.height)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDouble(double? value) {
    if (value == null) return '-';
    return value.toStringAsFixed(1);
  }
}
