import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../functions/ui/app_bar.dart';

class MissingRouteDataPage extends StatelessWidget {
  const MissingRouteDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final routeName = _resolveRouteName(context);

    return Title(
      title: 'Phyto Glow',
      color: const Color(0xFF3F51B5),
      child: Scaffold(
        appBar: getAppBar(context, 'Phyto Glow'),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ไม่พบข้อมูล',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'ดูเหมือนว่าคุณพยายามเปิดหน้า $routeName แต่ว่าไม่มีข้อมูลในการแสดงผล ทำให้ไม่สามารถแสดงข้อมูลในหน้านี้ได้',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: FilledButton.icon(
                          onPressed: () => context.goNamed('home'),
                          icon: const Icon(Icons.home_rounded),
                          label: const Text('กลับหน้าแรก'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _resolveRouteName(BuildContext context) {
    try {
      return GoRouterState.of(context).name ?? 'ที่ไม่ทราบชื่อ';
    } catch (_) {
      return 'ที่ไม่ทราบชื่อ';
    }
  }
}
