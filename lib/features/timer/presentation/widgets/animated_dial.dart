import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme.dart';

class AnimatedDial extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String timeText;
  final bool isRunning;

  const AnimatedDial({
    super.key,
    required this.progress,
    required this.timeText,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.background,
            boxShadow: [
              if (isRunning)
                BoxShadow(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.05),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background Track
              CustomPaint(
                size: const Size(280, 280),
                painter: DialPainter(
                  progress: 1.0,
                  color: AppTheme.surface,
                  strokeWidth: 2,
                ),
              ),
              // Progress Track
              CustomPaint(
                size: const Size(280, 280),
                painter: DialPainter(
                  progress: progress,
                  color: AppTheme.primaryAccent,
                  strokeWidth: 4,
                ),
              ),
              // Time Text
              Text(
                    timeText,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: isRunning
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                  .animate(target: isRunning ? 1 : 0)
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.05, 1.05),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  )
                  .tint(color: AppTheme.textPrimary, duration: 300.ms),
            ],
          ),
        )
        .animate(target: isRunning ? 1 : 0)
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.03, 1.03),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        );
  }
}

class DialPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  DialPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant DialPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
