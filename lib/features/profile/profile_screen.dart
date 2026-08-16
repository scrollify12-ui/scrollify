import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/providers/user_provider.dart';
import '../../repository/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: userAsync.when(
          data: (user) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      color: AppColors.surfaceVariant,
                      image: user.profilePhoto != null
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(user.profilePhoto!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: user.profilePhoto == null
                        ? const Center(
                            child: Icon(Icons.person, size: 50, color: AppColors.textSecondary),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Name and Handle
                  Text(
                    user.fullName,
                    style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username}',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.monetization_on,
                          iconColor: AppColors.primary,
                          value: '${user.points}',
                          label: 'Total Points',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.local_fire_department,
                          iconColor: Colors.orange,
                          value: '${user.currentStreak}',
                          label: 'Day Streak',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Menu List
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(Icons.people_outline, 'Friend List', trailingText: '${user.friendsCount} Friends'),
                        _buildDivider(),
                        _buildMenuItem(Icons.emoji_events_outlined, 'Achievements', trailingText: '${user.badgesCount} Badges'),
                        _buildDivider(),
                        _buildMenuItem(Icons.bar_chart_rounded, 'My Stats'),
                        _buildDivider(),
                        _buildMenuItem(Icons.card_giftcard, 'Offers & Bonus'),
                        _buildDivider(),
                        _buildMenuItem(Icons.account_balance_wallet_outlined, 'Wallet', trailingText: '${user.walletBalance}', trailingIcon: Icons.monetization_on),
                        _buildDivider(),
                        _buildMenuItem(Icons.settings_outlined, 'Settings'),
                        _buildDivider(),
                        _buildMenuItem(Icons.help_outline, 'Help & Support'),
                        _buildDivider(),
                        _buildMenuItem(Icons.logout, 'Log Out', onTap: () async {
                          await ref.read(authRepositoryProvider).logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, st) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text('Error loading profile', style: AppTextStyles.bodyLarge),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.invalidate(userProvider),
                  child: const Text('Retry'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required Color iconColor, required String value, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? trailingText, IconData? trailingIcon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 16),
          Text(
            title,
            style: AppTextStyles.bodyLarge,
          ),
          const Spacer(),
          if (trailingText != null) ...[
            Text(
              trailingText,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(width: 4),
          ],
          if (trailingIcon != null) ...[
            Icon(trailingIcon, color: AppColors.primary, size: 16),
            const SizedBox(width: 4),
          ],
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
        ],
      ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.divider,
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
