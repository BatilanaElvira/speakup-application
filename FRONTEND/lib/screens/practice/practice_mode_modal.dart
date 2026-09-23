import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/practice_session.dart';

class PracticeModeSelectorModal extends StatelessWidget {
  final ValueChanged<PracticeMode> onModeSelected;

  const PracticeModeSelectorModal({super.key, required this.onModeSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'CHOOSE PRACTICE MODE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainText,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select how deep you want to practice today.',
                style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 20),

              // 1. Quick Practice Card
              _buildModeOption(
                context,
                mode: PracticeMode.quick,
                iconEmoji: '🟢',
                title: 'Daily Quick Practice',
                durationTag: '1–3 MIN HABIT BUILDER',
                description: 'Fast, zero-pressure habit challenge. Ideal for maintaining daily momentum.',
                accentColor: AppColors.successGreen,
              ),
              const SizedBox(height: 12),

              // 2. Full Practice Card
              _buildModeOption(
                context,
                mode: PracticeMode.full,
                iconEmoji: '🔵',
                title: 'Full AI Evaluation Session',
                durationTag: '5–10 MIN DEEP ANALYSIS',
                description: 'Complete practice flow with custom evaluator, transcript, metrics, and coach feedback.',
                accentColor: AppColors.primaryBlue,
              ),
              const SizedBox(height: 12),

              // 3. Goal Roadmap Card
              _buildModeOption(
                context,
                mode: PracticeMode.goal,
                iconEmoji: '🟣',
                title: 'Goal / Journey Exercise',
                durationTag: 'PROBLEM-BASED ROADMAP',
                description: 'Targeted scenario exercises linked directly to your current obstacle (e.g. Confidence, Clarity).',
                accentColor: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeOption(
    BuildContext context, {
    required PracticeMode mode,
    required String iconEmoji,
    required String title,
    required String durationTag,
    required String description,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onModeSelected(mode);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Text(iconEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.mainText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      durationTag,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.secondaryText, size: 16),
          ],
        ),
      ),
    );
  }
}
