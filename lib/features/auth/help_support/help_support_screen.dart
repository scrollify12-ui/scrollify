import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'widgets/support_option_item.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Help & Support',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'How can we help you?',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    SupportOptionItem(
                      iconData: Icons.lock_outline,
                      title: 'Forgot Password',
                      subtitle: 'Reset your account password',
                      onTap: () {},
                    ),
                    SupportOptionItem(
                      iconData: Icons.person_outline,
                      title: 'New User?',
                      subtitle: 'How to sign up on Scrollify',
                      onTap: () {},
                    ),
                    SupportOptionItem(
                      iconData: Icons.help_outline,
                      title: 'Login Help',
                      subtitle: 'Issues while logging in?',
                      onTap: () {},
                    ),
                    SupportOptionItem(
                      iconData: Icons.shield_outlined,
                      title: 'Account & Security',
                      subtitle: 'Keep your account safe',
                      onTap: () {},
                    ),
                    SupportOptionItem(
                      iconData: Icons.forum_outlined,
                      title: 'FAQs',
                      subtitle: 'Find quick answers here',
                      onTap: () {},
                    ),
                    SupportOptionItem(
                      iconData: Icons.support_agent,
                      title: 'Contact Support',
                      subtitle: "We're here to help!",
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Fixed bottom footer for Email
      bottomSheet: Container(
        color: Colors.black.withValues(alpha: 0.9),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2a2a2a),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.email_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Us',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'support@scrollify.app',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
