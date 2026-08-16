import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/leaderboard_provider.dart';

class LeaderboardFilter extends ConsumerWidget {
  const LeaderboardFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(leaderboardFilterProvider);
    final options = ['Today', 'This Week', 'All Time'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Row(
          children: List.generate(options.length, (index) {
            final option = options[index];
            final isSelected = selectedFilter == option;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  ref.read(leaderboardFilterProvider.notifier).state = option;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.divider : Colors.transparent,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    options[index],
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
