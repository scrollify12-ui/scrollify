/// Fetches, caches, and provides RemoteConfig from the backend.
/// - On success: caches JSON in SharedPreferences
/// - On failure: uses cached value if fresh, else falls back to defaults
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'remote_config_model.dart';

class RemoteConfigService {
  final SharedPreferences _prefs;

  RemoteConfigService(this._prefs);

  /// Fetch config from server, cache it, and return it.
  /// On any error, returns cached or default config — never throws.
  Future<RemoteConfigModel> fetchAndCache() async {
    try {
      final uri = Uri.parse('${AppConfig.backendBaseUrl}/api/config');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final config = RemoteConfigModel.fromJson(json);

        // Cache to SharedPreferences
        await _prefs.setString(AppConfig.configCacheKey, response.body);
        await _prefs.setString(
          AppConfig.configCacheTimestampKey,
          DateTime.now().toIso8601String(),
        );

        return config;
      }
    } catch (e) {
      // Network error, timeout, JSON parse error, etc. — silent fallback
      debugPrint('[RemoteConfig] Fetch failed: $e');
    }

    return _loadCachedOrDefault();
  }

  /// Load from cache if it exists, otherwise return defaults.
  RemoteConfigModel getCached() => _loadCachedOrDefault();

  RemoteConfigModel _loadCachedOrDefault() {
    final cached = _prefs.getString(AppConfig.configCacheKey);
    if (cached != null) {
      try {
        final json = jsonDecode(cached) as Map<String, dynamic>;
        return RemoteConfigModel.fromJson(json);
      } catch (_) {
        // Corrupted cache — clear it
        _prefs.remove(AppConfig.configCacheKey);
      }
    }
    return RemoteConfigModel.defaults();
  }

  /// Whether cached config is still fresh (within TTL).
  bool isCacheFresh() {
    final timestampStr = _prefs.getString(AppConfig.configCacheTimestampKey);
    if (timestampStr == null) return false;
    final timestamp = DateTime.tryParse(timestampStr);
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < AppConfig.configCacheTtl;
  }
}

// Workaround for dart:ui dependency in service layer
void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
