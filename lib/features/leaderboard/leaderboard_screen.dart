import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../home/widgets/home_header.dart'; // Reusing header from home
import 'widgets/leaderboard_filter.dart';
import 'widgets/leaderboard_item.dart';
import 'widgets/invite_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const HomeHeader(),
                const LeaderboardFilter(),
                Expanded(
                  child: leaderboardAsync.when(
                    data: (users) {
                      if (users.isEmpty) {
                        return const Center(
                          child: Text(
                            'No leaderboard data yet.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: users.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) return const SizedBox(height: 8);
                          if (index == users.length + 1) return const SizedBox(height: 100); // padding for invite btn
                          
                          final user = users[index - 1];
                          final isCurrent = user.id == 'current_user';
                          final rank = index;
                          
                          return LeaderboardItem(
                            rank: '$rank',
                            name: user.fullName,
                            score: '${user.points}',
                            avatarColor: AppColors.primary,
                            isCurrentUser: isCurrent,
                            rankIcon: rank <= 3 && rank > 0 ? Icons.emoji_events : null,
                            rankIconColor: rank == 1 ? AppColors.primary : (rank == 2 ? Colors.grey : (rank == 3 ? Colors.orangeAccent : null)),
                          ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1, end: 0);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => const Center(child: Text('Failed to load leaderboard')),
                  ),
                ),
              ],
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: InviteButton(),
            ),
          ],
        ),
      ),
    );
  }
}
