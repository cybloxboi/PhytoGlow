import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

AppBar getAppBar(BuildContext context, String title, {List<Widget>? actions}) {
  final navigator = Navigator.of(context);
  final state = _maybeGoRouterState(context);
  final isHome = state?.name == 'home';
  final shouldShowBackButton = navigator.canPop() || !isHome;

  return AppBar(
    leading: shouldShowBackButton
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              if (navigator.canPop()) {
                context.pop();
                return;
              }

              context.goNamed('home');
            },
          )
        : null,
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    actions: actions,
    elevation: 5,
  );
}

GoRouterState? _maybeGoRouterState(BuildContext context) {
  try {
    return GoRouterState.of(context);
  } catch (_) {
    return null;
  }
}
