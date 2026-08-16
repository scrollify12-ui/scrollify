import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/reel_state_provider.dart';

class AppUsage extends ConsumerWidget {
  const AppUsage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read from the unified provider
    final reelState = ref.watch(reelStateProvider);
    final stats = reelState.appUsageList;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App Usage',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: stats.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'No activity yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : Column(
                    children: stats.map((stat) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildAppRow(
                        name: stat.appName,
                        reelsCount: stat.reelsCount,
                        maxReels: 100, // assuming 100 limit
                        iconWidget: stat.iconData is IconData
                            ? Icon(stat.iconData, color: stat.iconFgColor ?? Colors.white, size: 24)
                            : FaIcon(stat.iconData, color: stat.iconFgColor ?? Colors.white, size: 24),
                        iconBackgroundColor: stat.iconColor,
                      ),
                    )).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppRow({
    required String name,
    required int reelsCount,
    required int maxReels,
    required Widget iconWidget,
    Color? iconBackgroundColor,
    Gradient? iconGradient,
  }) {
    final double progress = maxReels > 0 ? reelsCount / maxReels : 0;
    
    String unit = 'reels';
    if (name == 'YouTube') {
      unit = 'shorts';
    } else if (name == 'Snapchat') {
      unit = 'Spotlight';
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // App Icon
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            gradient: iconGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: iconWidget,
        ),
        const SizedBox(width: 16),
        // App Details and Progress
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$reelsCount $unit',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFF2A2A2A),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
