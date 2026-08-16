import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/rewards_provider.dart';
import 'reward_item.dart';

class RewardsList extends ConsumerWidget {
  const RewardsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsAsync = ref.watch(rewardsProvider);
    
    return rewardsAsync.when(
      data: (rewards) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Redeem Rewards',
                style: AppTextStyles.labelLarge,
              ),
              const SizedBox(height: 16),
              if (rewards.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text(
                      'Rewards will appear here once available.',
                      style: TextStyle(color: Color(0xFF9E9E9E)), // Used direct color to keep const, or we can just remove const
                    ),
                  ),
                )
              else
                ...rewards.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reward = entry.value;
                  return RewardItem(
                    title: reward.title,
                    subtitle: reward.subtitle,
                    points: '${reward.pointsCost}',
                    icon: reward.icon,
                  ).animate().fadeIn(delay: Duration(milliseconds: 200 + (index * 100))).slideY(begin: 0.2, end: 0);
                }),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const Center(child: Text('Failed to load rewards')),
    );
  }
}
