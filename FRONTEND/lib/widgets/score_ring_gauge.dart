import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../constants/app_colors.dart';

class ScoreRingGauge extends StatelessWidget {
  final int score;
  final String label;
  final double radius;
  final double lineWidth;
  final Color? color;

  const ScoreRingGauge({
    super.key,
    required this.score,
    required this.label,
    this.radius = 60.0,
    this.lineWidth = 10.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (score >= 80
            ? AppColors.successGreen
            : score >= 65
                ? AppColors.warningAmber
                : AppColors.errorRed);

    return CircularPercentIndicator(
      radius: radius,
      lineWidth: lineWidth,
      percent: (score / 100).clamp(0.0, 1.0),
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$score%',
            style: TextStyle(
              fontSize: radius * 0.45,
              fontWeight: FontWeight.bold,
              color: AppColors.mainText,
            ),
          ),
          if (label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      progressColor: effectiveColor,
      backgroundColor: effectiveColor.withValues(alpha: 0.15),
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 1200,
    );
  }
}
