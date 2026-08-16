import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../repository/auth_repository.dart';
import '../../../../repository/profile_repository.dart';
import '../../../../core/providers/user_provider.dart';
import 'widgets/auth_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              
              // Hero Illustration (Logo)
              Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 48),

              // Welcome Text
              Text(
                'Welcome to ',
                style: AppTextStyles.headlineMedium,
              ),
              Text(
                'SCROLLIFY',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scroll less. Save time. Win rewards.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              // Auth Buttons
              AuthButton(
                text: 'Continue with Google',
                imageAsset: 'assets/images/googlelogo.png',
                backgroundColor: Colors.white,
                textColor: Colors.black,
                border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
                shadowColor: Colors.black.withValues(alpha: 0.05),
                onTap: () async {
                  final authRepo = ref.read(authRepositoryProvider);
                  final profileRepo = ref.read(profileRepositoryProvider);
                  
                  try {
                    await authRepo.loginWithGoogle();
                    
                    if (!context.mounted) return;
                    
                    final isLoggedIn = await authRepo.isLoggedIn();
                    if (!isLoggedIn) return; // User might have canceled the flow
                    
                    final isProfileComplete = await profileRepo.isProfileComplete();
                    
                    if (!context.mounted) return;
                    
                    if (isProfileComplete) {
                      ref.invalidate(userProvider);
                      context.go('/home');
                    } else {
                      context.go('/complete-profile');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Login failed: $e')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              AuthButton(
                text: 'Continue with Instagram',
                imageAsset: 'assets/images/instagram_logo.png',
                textColor: Colors.white,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6A3D), Color(0xFFFF3F6C), Color(0xFF9C27B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shadowColor: const Color(0xFFDD2A7B).withValues(alpha: 0.3),
                onTap: () async {
                  final authRepo = ref.read(authRepositoryProvider);
                  final profileRepo = ref.read(profileRepositoryProvider);
                  
                  await authRepo.loginWithInstagram();
                  
                  if (!context.mounted) return;
                  
                  final isProfileComplete = await profileRepo.isProfileComplete();
                  
                  if (!context.mounted) return;
                  
                  if (isProfileComplete) {
                    ref.invalidate(userProvider);
                    context.go('/home');
                  } else {
                    context.go('/complete-profile');
                  }
                },
              ),

              const Spacer(),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.divider)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'OR',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.divider)),
                ],
              ),
              const SizedBox(height: 24),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Login',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Footer Help
              Column(
                children: [
                  Text(
                    'Having trouble?',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      context.push('/help-support');
                    },
                    child: Text(
                      'Get Help',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
