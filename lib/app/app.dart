import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class ScrollifyApp extends StatelessWidget {
  const ScrollifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Scrollify',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
