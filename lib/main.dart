import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'core/storage/local_storage_service.dart';
import 'core/remote_config/remote_config_service.dart';
import 'core/remote_config/remote_config_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final localStorage = LocalStorageService(prefs);
  final remoteConfigService = RemoteConfigService(prefs);

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(localStorage),
        remoteConfigServiceProvider.overrideWithValue(remoteConfigService),
      ],
      child: const ScrollifyApp(),
    ),
  );
}
