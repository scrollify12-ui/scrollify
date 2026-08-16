import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/remote_config/remote_config_provider.dart';
import '../../repository/auth_repository.dart';
import '../../repository/profile_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print("Splash started");

      // ── Step 1: Fetch remote config (non-blocking on failure) ──
      // Run in background — if it fails, defaults kick in
      unawaited(
        ref.read(remoteConfigProvider.notifier).refresh().catchError((_) {}),
      );

      if (kIsWeb) {
        print("Running on Web, bypassing Firebase and jumping to Login");
        Future.microtask(() {
          if (mounted) context.go('/login');
        });
        return;
      }

      // ── Step 2: Initialize Firebase ────────────────────────────
      print("Initializing Firebase...");
      await Firebase.initializeApp().timeout(const Duration(seconds: 10));
      print("Firebase initialized");

      if (!mounted) return;

      // ── Step 3: Auth check ─────────────────────────────────────
      final authRepo = ref.read(authRepositoryProvider);
      final profileRepo = ref.read(profileRepositoryProvider);

      print("Checking auth...");
      final isLoggedIn = await authRepo.isLoggedIn().timeout(const Duration(seconds: 10));
      print("Auth result: isLoggedIn=$isLoggedIn");

      if (!mounted) return;

      if (!isLoggedIn) {
        print("Navigating to: /login");
        context.go('/login');
      } else {
        print("Checking profile...");
        final isProfileComplete = await profileRepo.isProfileComplete().timeout(const Duration(seconds: 10));
        print("Profile result: isProfileComplete=$isProfileComplete");
        if (!mounted) return;

        if (!isProfileComplete) {
          print("Navigating to: /complete-profile");
          context.go('/complete-profile');
        } else {
          print("Navigating to: /home");
          context.go('/home');
        }
      }
    } catch (e, stackTrace) {
      print("Error in Splash Screen initialization: $e");
      print(stackTrace);
      if (mounted) {
        print("Navigating to: /login (due to error)");
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              'SCROLLIFY',
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 4.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fire-and-forget helper
void unawaited(Future<void> future) {}
