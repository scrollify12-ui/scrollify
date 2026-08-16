import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../search/search_screen.dart';
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64, // Fixed navbar height
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo that can scale up without expanding navbar height
            Transform.translate(
              offset: const Offset(-16, 0), // Shift the logo to the left
              child: Transform.scale(
                scale: 2.2, // Visually increase size significantly (over 100%) to compensate for any transparent padding in the image
                alignment: Alignment.centerLeft, // Keep it anchored to the left
                child: Image.asset(
                  'assets/images/navbar_logo.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                context.push('/search');
              },
              icon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
                size: 28,
              ),
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
