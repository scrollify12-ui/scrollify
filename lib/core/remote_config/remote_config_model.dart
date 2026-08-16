/// Strongly-typed model for all remote config values.
/// Includes defaults so the app works even if the backend is unreachable.
import 'dart:ui';

class RemoteConfigModel {
  // ── App metadata ────────────────────────────────────────────
  final String appName;
  final String appTagline;
  final String supportEmail;
  final String minSupportedVersion;

  // ── Feature flags ────────────────────────────────────────────
  final bool leaderboardEnabled;
  final bool rewardsEnabled;
  final bool searchEnabled;
  final bool socialEnabled;
  final bool reelCounterEnabled;

  // ── Gamification ─────────────────────────────────────────────
  final int dailyReelLimit;
  final int pointsPerReel;
  final double streakBonusMultiplier;
  final int maxStreakBonusDays;

  // ── Theme overrides (null = use compiled default) ─────────────
  final Color? primaryColor;
  final Color? backgroundColor;
  final Color? surfaceColor;

  // ── Announcement banner ───────────────────────────────────────
  final bool bannerEnabled;
  final String bannerMessage;
  final String bannerType; // "info" | "warning" | "error" | "success"
  final String? bannerImageUrl;
  final String? bannerActionUrl;
  final String? bannerActionLabel;

  // ── Config versioning ─────────────────────────────────────────
  final int configVersion;
  final DateTime? fetchedAt;

  const RemoteConfigModel({
    required this.appName,
    required this.appTagline,
    required this.supportEmail,
    required this.minSupportedVersion,
    required this.leaderboardEnabled,
    required this.rewardsEnabled,
    required this.searchEnabled,
    required this.socialEnabled,
    required this.reelCounterEnabled,
    required this.dailyReelLimit,
    required this.pointsPerReel,
    required this.streakBonusMultiplier,
    required this.maxStreakBonusDays,
    this.primaryColor,
    this.backgroundColor,
    this.surfaceColor,
    required this.bannerEnabled,
    required this.bannerMessage,
    required this.bannerType,
    this.bannerImageUrl,
    this.bannerActionUrl,
    this.bannerActionLabel,
    required this.configVersion,
    this.fetchedAt,
  });

  /// Compiled-in defaults — app works fully offline with these.
  factory RemoteConfigModel.defaults() {
    return const RemoteConfigModel(
      appName: 'Scrollify',
      appTagline: 'Scroll smarter, not harder.',
      supportEmail: 'support@scrollify.app',
      minSupportedVersion: '1.0.0',
      leaderboardEnabled: true,
      rewardsEnabled: true,
      searchEnabled: true,
      socialEnabled: true,
      reelCounterEnabled: true,
      dailyReelLimit: 30,
      pointsPerReel: 10,
      streakBonusMultiplier: 1.5,
      maxStreakBonusDays: 7,
      bannerEnabled: false,
      bannerMessage: '',
      bannerType: 'info',
      configVersion: 0,
    );
  }

  factory RemoteConfigModel.fromJson(Map<String, dynamic> json) {
    final features = json['features'] as Map<String, dynamic>? ?? {};
    final gamification = json['gamification'] as Map<String, dynamic>? ?? {};
    final theme = json['theme'] as Map<String, dynamic>? ?? {};
    final banner = json['banner'] as Map<String, dynamic>? ?? {};

    return RemoteConfigModel(
      appName: json['app_name'] as String? ?? 'Scrollify',
      appTagline: json['app_tagline'] as String? ?? 'Scroll smarter, not harder.',
      supportEmail: json['support_email'] as String? ?? 'support@scrollify.app',
      minSupportedVersion: json['min_supported_version'] as String? ?? '1.0.0',

      leaderboardEnabled: features['leaderboard_enabled'] as bool? ?? true,
      rewardsEnabled: features['rewards_enabled'] as bool? ?? true,
      searchEnabled: features['search_enabled'] as bool? ?? true,
      socialEnabled: features['social_enabled'] as bool? ?? true,
      reelCounterEnabled: features['reel_counter_enabled'] as bool? ?? true,

      dailyReelLimit: gamification['daily_reel_limit'] as int? ?? 30,
      pointsPerReel: gamification['points_per_reel'] as int? ?? 10,
      streakBonusMultiplier: (gamification['streak_bonus_multiplier'] as num?)?.toDouble() ?? 1.5,
      maxStreakBonusDays: gamification['max_streak_bonus_days'] as int? ?? 7,

      primaryColor: _parseColor(theme['primary_color'] as String?),
      backgroundColor: _parseColor(theme['background_color'] as String?),
      surfaceColor: _parseColor(theme['surface_color'] as String?),

      bannerEnabled: banner['enabled'] as bool? ?? false,
      bannerMessage: banner['message'] as String? ?? '',
      bannerType: banner['type'] as String? ?? 'info',
      bannerImageUrl: banner['image_url'] as String?,
      bannerActionUrl: banner['action_url'] as String?,
      bannerActionLabel: banner['action_label'] as String?,

      configVersion: json['config_version'] as int? ?? 0,
      fetchedAt: json['fetched_at'] != null
          ? DateTime.tryParse(json['fetched_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_name': appName,
      'app_tagline': appTagline,
      'support_email': supportEmail,
      'min_supported_version': minSupportedVersion,
      'features': {
        'leaderboard_enabled': leaderboardEnabled,
        'rewards_enabled': rewardsEnabled,
        'search_enabled': searchEnabled,
        'social_enabled': socialEnabled,
        'reel_counter_enabled': reelCounterEnabled,
      },
      'gamification': {
        'daily_reel_limit': dailyReelLimit,
        'points_per_reel': pointsPerReel,
        'streak_bonus_multiplier': streakBonusMultiplier,
        'max_streak_bonus_days': maxStreakBonusDays,
      },
      'theme': {
        'primary_color': primaryColor != null ? '#${primaryColor!.toARGB32().toRadixString(16).substring(2).toUpperCase()}' : null,
        'background_color': backgroundColor != null ? '#${backgroundColor!.toARGB32().toRadixString(16).substring(2).toUpperCase()}' : null,
        'surface_color': surfaceColor != null ? '#${surfaceColor!.toARGB32().toRadixString(16).substring(2).toUpperCase()}' : null,
      },
      'banner': {
        'enabled': bannerEnabled,
        'message': bannerMessage,
        'type': bannerType,
        'image_url': bannerImageUrl,
        'action_url': bannerActionUrl,
        'action_label': bannerActionLabel,
      },
      'config_version': configVersion,
      'fetched_at': fetchedAt?.toIso8601String(),
    };
  }

  RemoteConfigModel copyWith({
    String? appName,
    String? appTagline,
    String? supportEmail,
    String? minSupportedVersion,
    bool? leaderboardEnabled,
    bool? rewardsEnabled,
    bool? searchEnabled,
    bool? socialEnabled,
    bool? reelCounterEnabled,
    int? dailyReelLimit,
    int? pointsPerReel,
    double? streakBonusMultiplier,
    int? maxStreakBonusDays,
    Color? primaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    bool? bannerEnabled,
    String? bannerMessage,
    String? bannerType,
    String? bannerImageUrl,
    String? bannerActionUrl,
    String? bannerActionLabel,
    int? configVersion,
    DateTime? fetchedAt,
  }) {
    return RemoteConfigModel(
      appName: appName ?? this.appName,
      appTagline: appTagline ?? this.appTagline,
      supportEmail: supportEmail ?? this.supportEmail,
      minSupportedVersion: minSupportedVersion ?? this.minSupportedVersion,
      leaderboardEnabled: leaderboardEnabled ?? this.leaderboardEnabled,
      rewardsEnabled: rewardsEnabled ?? this.rewardsEnabled,
      searchEnabled: searchEnabled ?? this.searchEnabled,
      socialEnabled: socialEnabled ?? this.socialEnabled,
      reelCounterEnabled: reelCounterEnabled ?? this.reelCounterEnabled,
      dailyReelLimit: dailyReelLimit ?? this.dailyReelLimit,
      pointsPerReel: pointsPerReel ?? this.pointsPerReel,
      streakBonusMultiplier: streakBonusMultiplier ?? this.streakBonusMultiplier,
      maxStreakBonusDays: maxStreakBonusDays ?? this.maxStreakBonusDays,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      bannerEnabled: bannerEnabled ?? this.bannerEnabled,
      bannerMessage: bannerMessage ?? this.bannerMessage,
      bannerType: bannerType ?? this.bannerType,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      bannerActionUrl: bannerActionUrl ?? this.bannerActionUrl,
      bannerActionLabel: bannerActionLabel ?? this.bannerActionLabel,
      configVersion: configVersion ?? this.configVersion,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  static Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return null;
    return Color(cleaned.length == 6 ? 0xFF000000 | value : value);
  }
}
