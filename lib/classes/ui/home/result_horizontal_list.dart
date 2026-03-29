import 'package:flutter/material.dart';
import 'package:phyto_glow/classes/ui/home/result_card.dart';

import '../../models/detection_result.dart';

class ResultHorizontalList extends StatelessWidget {
  final List<DetectionResult> items;
  final ValueChanged<DetectionResult>? onItemTap;

  const ResultHorizontalList({super.key, required this.items, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(items.length * 2 - 1, (index) {
          if (index.isOdd) {
            return const SizedBox(width: 12);
          }

          final item = items[index ~/ 2];
          return ResultCard(
            item: item,
            onTap: onItemTap == null ? null : () => onItemTap!(item),
          );
        }),
      ),
    );
  }
}
