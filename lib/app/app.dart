import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/remote_config/remote_config_provider.dart';
import 'router.dart';

class ScrollifyApp extends ConsumerStatefulWidget {
  const ScrollifyApp({super.key});

  @override
  ConsumerState<ScrollifyApp> createState() => _ScrollifyAppState();
}

class _ScrollifyAppState extends ConsumerState<ScrollifyApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    // Refresh config when app comes back to foreground
    _lifecycleListener = AppLifecycleListener(
      onResume: _onAppResume,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _onAppResume() {
    // Refresh config in background on resume — only if cache is stale
    ref.read(remoteConfigProvider.notifier).refreshIfStale();
  }

  @override
  Widget build(BuildContext context) {
    final remoteConfig = ref.watch(remoteConfigProvider);

    // Build theme — apply remote overrides if provided, else use compiled defaults
    final theme = AppTheme.buildTheme(
      primaryColorOverride: remoteConfig.primaryColor,
      backgroundColorOverride: remoteConfig.backgroundColor,
      surfaceColorOverride: remoteConfig.surfaceColor,
    );

    return MaterialApp.router(
      title: remoteConfig.appName,
      theme: theme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
