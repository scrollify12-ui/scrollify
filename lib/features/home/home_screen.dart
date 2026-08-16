import 'package:flutter/material.dart';
import '../../core/services/native_reel_service.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/home_header.dart';
import 'widgets/progress_section.dart';
import 'widgets/app_usage.dart';
import 'widgets/todays_points.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPerm = await nativeReelService.checkAccessibilityPermission();
    if (mounted) {
      setState(() {
        _hasPermission = hasPerm;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeader(),
            if (!_hasPermission)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enable Accessibility to count reels automatically.',
                        style: TextStyle(color: Colors.redAccent[100], fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        await nativeReelService.openAccessibilitySettings();
                        // Check again after some delay or when app resumes
                        Future.delayed(const Duration(seconds: 3), _checkPermission);
                      },
                      child: const Text('ENABLE'),
                    ),
                  ],
                ),
              ),
            const Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ProgressSection(),
                    SizedBox(height: 24),
                    AppUsage(),
                    SizedBox(height: 24),
                    TodaysPoints(),
                    SizedBox(height: 24), // padding for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
