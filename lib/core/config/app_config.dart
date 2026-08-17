/// Centralizes environment-based configuration for the Scrollify app.
/// All code should read from AppConfig instead of doing inline kReleaseMode checks.
import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  // ── App version (keep in sync with pubspec.yaml) ──────────────
  static const String appVersion = '1.0.3';
  static const int appBuildNumber = 4;

  // ── Backend URLs ──────────────────────────────────────────────
  /// Use production URL on release builds and all web builds.
  /// Use local IP on debug Android/iOS builds.
  static String get apiBaseUrl {
    if (kReleaseMode || kIsWeb) {
      return 'https://scrollify-backend.onrender.com/api/';
    }
    return 'http://192.168.1.5:3000/api/';
  }

  /// Base URL without the /api/ suffix — used for config fetch
  static String get backendBaseUrl {
    if (kReleaseMode || kIsWeb) {
      return 'https://scrollify-backend.onrender.com';
    }
    return 'http://192.168.1.5:3000';
  }

  // ── Remote Config ─────────────────────────────────────────────
  static const Duration configCacheTtl = Duration(hours: 1);
  static const String configCacheKey = 'remote_config_json';
  static const String configCacheTimestampKey = 'remote_config_fetched_at';
}
