import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/reel_state_provider.dart';

class ActionCards extends ConsumerWidget {
  const ActionCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          _ActionCard(
            title: 'Scroll Less',
            subtitle: 'Save your screen time.',
            highlight: 'Demo: Add 1 Reel',
            icon: Icons.eco_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reel count is now tracked automatically in the background!')),
              );
            },
          ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1, end: 0),
          const SizedBox(height: 16),
          _ActionCard(
            title: 'Compete & Earn',
            subtitle: 'Scroll more, hit targets\n& win rewards!',
            icon: Icons.emoji_events_outlined,
            iconBgColor: AppColors.primary.withValues(alpha: 0.1),
            onTap: () {},
          ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? highlight;
  final IconData icon;
  final Color? iconBgColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    this.highlight,
    required this.icon,
    this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor ?? Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                  if (highlight != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      highlight!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
