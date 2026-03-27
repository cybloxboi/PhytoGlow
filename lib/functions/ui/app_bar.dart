import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

AppBar getAppBar(BuildContext context, String title) {
  final navigator = Navigator.of(context);
  final router = GoRouter.of(context);
  final currentLocation = router.routeInformationProvider.value.uri.path;
  final shouldShowBackButton = navigator.canPop() || currentLocation != '/';

  return AppBar(
    leading: shouldShowBackButton
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              if (navigator.canPop()) {
                context.pop();
                return;
              }

              router.goNamed('home');
            },
          )
        : null,
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    elevation: 5,
  );
}
