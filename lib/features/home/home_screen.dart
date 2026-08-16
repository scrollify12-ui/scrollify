import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/native_reel_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/remote_config/remote_config_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/progress_section.dart';
import 'widgets/app_usage.dart';
import 'widgets/todays_points.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPerm = await nativeReelService.checkAccessibilityPermission();
    if (mounted) {
      setState(() {
        _hasPermission = hasPerm;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final banner = ref.watch(bannerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeader(),

            // ── Remote config: Accessibility permission warning ──
            if (!_hasPermission)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enable Accessibility to count reels automatically.',
                        style: TextStyle(color: Colors.redAccent[100], fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await nativeReelService.openAccessibilitySettings();
                        Future.delayed(const Duration(seconds: 3), _checkPermission);
                      },
                      child: const Text('ENABLE'),
                    ),
                  ],
                ),
              ),

            // ── Remote config: Announcement banner ──────────────
            if (banner.enabled && banner.message.isNotEmpty)
              _RemoteBanner(banner: banner),

            const Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ProgressSection(),
                    SizedBox(height: 24),
                    AppUsage(),
                    SizedBox(height: 24),
                    TodaysPoints(),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Remote Banner Widget ───────────────────────────────────────────
class _RemoteBanner extends StatelessWidget {
  final ({
    bool enabled,
    String message,
    String type,
    String? imageUrl,
    String? actionUrl,
    String? actionLabel,
  }) banner;

  const _RemoteBanner({required this.banner});

  Color get _bgColor {
    switch (banner.type) {
      case 'warning': return Colors.orange.withOpacity(0.15);
      case 'error':   return Colors.red.withOpacity(0.15);
      case 'success': return Colors.green.withOpacity(0.15);
      default:        return AppColors.primary.withOpacity(0.10);
    }
  }

  Color get _borderColor {
    switch (banner.type) {
      case 'warning': return Colors.orange.withOpacity(0.5);
      case 'error':   return Colors.red.withOpacity(0.5);
      case 'success': return Colors.green.withOpacity(0.5);
      default:        return AppColors.primary.withOpacity(0.4);
    }
  }

  IconData get _icon {
    switch (banner.type) {
      case 'warning': return Icons.warning_amber_rounded;
      case 'error':   return Icons.error_outline_rounded;
      case 'success': return Icons.check_circle_outline_rounded;
      default:        return Icons.info_outline_rounded;
    }
  }

  Color get _iconColor {
    switch (banner.type) {
      case 'warning': return Colors.orange;
      case 'error':   return Colors.red;
      case 'success': return Colors.green;
      default:        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bgColor,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              banner.message,
              style: TextStyle(color: _iconColor, fontSize: 12),
            ),
          ),
          if (banner.actionLabel != null)
            TextButton(
              onPressed: () {
                // TODO: handle action_url via url_launcher when needed
              },
              child: Text(banner.actionLabel!),
            ),
        ],
      ),
    );
  }
}
