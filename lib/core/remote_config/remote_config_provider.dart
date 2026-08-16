/// Riverpod providers for RemoteConfig.
/// Usage:
///   final config = ref.watch(remoteConfigProvider);
///   if (config.leaderboardEnabled) { ... }
///
/// To trigger a refresh (e.g. on app resume):
///   ref.read(remoteConfigProvider.notifier).refresh();
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'remote_config_model.dart';
import 'remote_config_service.dart';

// ── Service provider ─────────────────────────────────────────────
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  throw UnimplementedError('remoteConfigServiceProvider not initialized');
});

// ── Notifier ─────────────────────────────────────────────────────
class RemoteConfigNotifier extends StateNotifier<RemoteConfigModel> {
  final RemoteConfigService _service;

  RemoteConfigNotifier(this._service)
      : super(_service.getCached()); // Initialize with cache or defaults

  /// Fetch fresh config from server and update state.
  /// Never throws — silently uses cached/default on failure.
  Future<void> refresh() async {
    final fresh = await _service.fetchAndCache();
    if (mounted) state = fresh;
  }

  /// Refresh only if cache is stale (respects TTL).
  Future<void> refreshIfStale() async {
    if (!_service.isCacheFresh()) {
      await refresh();
    }
  }
}

// ── State provider ────────────────────────────────────────────────
final remoteConfigProvider =
    StateNotifierProvider<RemoteConfigNotifier, RemoteConfigModel>(
  (ref) {
    final service = ref.watch(remoteConfigServiceProvider);
    return RemoteConfigNotifier(service);
  },
);

// ── Convenience selectors ─────────────────────────────────────────
final featureFlagsProvider = Provider<Map<String, bool>>((ref) {
  final config = ref.watch(remoteConfigProvider);
  return {
    'leaderboard': config.leaderboardEnabled,
    'rewards': config.rewardsEnabled,
    'search': config.searchEnabled,
    'social': config.socialEnabled,
    'reel_counter': config.reelCounterEnabled,
  };
});

final bannerProvider = Provider<({bool enabled, String message, String type, String? imageUrl, String? actionUrl, String? actionLabel})>((ref) {
  final config = ref.watch(remoteConfigProvider);
  return (
    enabled: config.bannerEnabled,
    message: config.bannerMessage,
    type: config.bannerType,
    imageUrl: config.bannerImageUrl,
    actionUrl: config.bannerActionUrl,
    actionLabel: config.bannerActionLabel,
  );
});
