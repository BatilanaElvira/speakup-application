import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/non_audio_exercise.dart';

class NonAudioExercisesScreen extends StatefulWidget {
  const NonAudioExercisesScreen({super.key});

  @override
  State<NonAudioExercisesScreen> createState() => _NonAudioExercisesScreenState();
}

class _NonAudioExercisesScreenState extends State<NonAudioExercisesScreen> {
  int _currentExIdx = 0;
  int? _selectedOptionIdx;
  bool _hasSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final exercise = NonAudioExercise.exercises[_currentExIdx];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'NON-AUDIO WRITTEN DRILLS',
          style: TextStyle(
            color: AppColors.mainText,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.glowShadow(AppColors.primaryBlue),
              ),
              child: Row(
                children: [
                  Text(exercise.iconEmoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXERCISE ${_currentExIdx + 1} OF ${NonAudioExercise.exercises.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          exercise.title,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+${exercise.xpReward} XP Reward',
                          style: const TextStyle(color: AppColors.warningAmber, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Prompt Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.cardShadow,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.description,
                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    exercise.prompt,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainText,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Options List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exercise.options.length,
              itemBuilder: (context, idx) {
                final isSelected = _selectedOptionIdx == idx;
                final isCorrect = idx == exercise.correctOptionIndex;

                Color borderColor = AppColors.cardBorder;
                Color bgColor = AppColors.white;

                if (_hasSubmitted) {
                  if (isCorrect) {
                    borderColor = AppColors.successGreen;
                    bgColor = AppColors.successGreen.withValues(alpha: 0.12);
                  } else if (isSelected) {
                    borderColor = AppColors.errorRed;
                    bgColor = AppColors.errorRed.withValues(alpha: 0.12);
                  }
                } else if (isSelected) {
                  borderColor = AppColors.primaryBlue;
                  bgColor = AppColors.primaryBlue.withValues(alpha: 0.08);
                }

                return GestureDetector(
                  onTap: _hasSubmitted
                      ? null
                      : () {
                          setState(() {
                            _selectedOptionIdx = idx;
                          });
                        },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor, width: isSelected || _hasSubmitted ? 2.0 : 1.0),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryBlue : AppColors.cardBorder.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            String.fromCharCode(65 + idx), // A, B, C, D
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.secondaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            exercise.options[idx],
                            style: const TextStyle(fontSize: 14, color: AppColors.mainText, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Submit / Next Button
            if (!_hasSubmitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedOptionIdx == null
                      ? null
                      : () {
                          setState(() {
                            _hasSubmitted = true;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('SUBMIT ANSWER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              )
            else ...[
              // Explanation Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 EXPLANATION:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                    const SizedBox(height: 4),
                    Text(exercise.explanation, style: const TextStyle(fontSize: 13, color: AppColors.mainText)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentExIdx = (_currentExIdx + 1) % NonAudioExercise.exercises.length;
                      _selectedOptionIdx = null;
                      _hasSubmitted = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('NEXT NON-AUDIO EXERCISE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
