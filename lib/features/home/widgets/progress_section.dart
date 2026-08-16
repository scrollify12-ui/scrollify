import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/reel_state_provider.dart';

class ProgressSection extends ConsumerWidget {
  const ProgressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reelState = ref.watch(reelStateProvider);
    final stats = reelState.dailyStats;

    final progress = stats.progressFraction;
    final displayValue = stats.reelsScrolledToday;
    
    return Column(
      children: [
        const SizedBox(height: 16),
        // Segmented Control
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              children: [
                _buildSegment('Today', true),
                _buildSegment('Yesterday', false),
                _buildSegment('Weekly Avg', false),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return CustomPaint(
                    size: const Size(250, 250),
                    painter: _ProgressPainter(
                      progress: value,
                      backgroundColor: AppColors.surfaceVariant,
                      gradientColors: const [Color(0xFF333333), Color(0xFF666666)], // Dark grey since it's empty
                    ),
                  );
                },
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: displayValue),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, value, child) {
                      return Text(
                        value.toString(),
                        style: AppTextStyles.displayLarge.copyWith(
                          fontSize: 64,
                          letterSpacing: -2,
                          height: 1.0,
                        ),
                      );
                    },
                  ),
                  Text(
                    'Reels',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'of 100',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 8),
        Text(
          '${stats.reelsRemaining} reels left',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 700.ms),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSegment(String text, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF332B14) : Colors.transparent, // Goldish tint for selected
          borderRadius: BorderRadius.circular(32),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final List<Color> gradientColors;

  _ProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 10;
    
    // Background Circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress Arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      colors: gradientColors,
      startAngle: -math.pi / 2,
      endAngle: math.pi * 1.5,
      transform: const GradientRotation(-math.pi / 2),
    );
    
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3); // subtle glow

    canvas.drawArc(
      rect,
      -math.pi / 2, // Start at top
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
