import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LeaderboardItem extends StatelessWidget {
  final String rank;
  final String name;
  final String score;
  final Color avatarColor;
  final Color avatarTextColor;
  final bool isCurrentUser;
  final IconData? rankIcon;
  final Color? rankIconColor;

  const LeaderboardItem({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
    required this.avatarColor,
    this.avatarTextColor = Colors.white,
    this.isCurrentUser = false,
    this.rankIcon,
    this.rankIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
      padding: isCurrentUser ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0) : const EdgeInsets.symmetric(vertical: 6.0),
      decoration: isCurrentUser
          ? BoxDecoration(
              color: const Color(0xFF1F1A0A), // Dark gold tint
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                child: Center(
                  child: rankIcon != null
                      ? Icon(rankIcon, color: rankIconColor, size: 16)
                      : Text(
                          rank,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: avatarTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                name,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isCurrentUser ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            score,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
