import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/journey.dart';
import '../../providers/app_provider.dart';
import '../../widgets/botanical_header.dart';

class ObstacleSelectorScreen extends StatelessWidget {
  final VoidCallback? onObstacleSelected;

  const ObstacleSelectorScreen({super.key, this.onObstacleSelected});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    final List<Map<String, dynamic>> goals = [
      {
        'title': 'Build Confidence',
        'subtitle': 'Overcome fear and speak freely',
        'icon': Icons.security_rounded,
        'color': AppColors.primaryCoral,
        'bgColor': const Color(0xFFFFECE8),
      },
      {
        'title': 'Improve Fluency',
        'subtitle': 'Speak smoothly and naturally',
        'icon': Icons.record_voice_over_rounded,
        'color': AppColors.sageGreen,
        'bgColor': AppColors.sageLightBg,
      },
      {
        'title': 'Clarity & Impact',
        'subtitle': 'Make your message clear',
        'icon': Icons.lightbulb_outline_rounded,
        'color': AppColors.warningAmber,
        'bgColor': const Color(0xFFFFF6E5),
      },
      {
        'title': 'Storytelling',
        'subtitle': 'Engage with powerful stories',
        'icon': Icons.auto_stories_rounded,
        'color': const Color(0xFF9C27B0),
        'bgColor': const Color(0xFFF7ECFD),
      },
      {
        'title': 'Presentation Skills',
        'subtitle': 'Deliver great presentations',
        'icon': Icons.co_present_rounded,
        'color': const Color(0xFF2196F3),
        'bgColor': const Color(0xFFE3F2FD),
      },
      {
        'title': 'Impromptu Speaking',
        'subtitle': 'Think fast, speak smart',
        'icon': Icons.bolt_rounded,
        'color': const Color(0xFFFF9800),
        'bgColor': const Color(0xFFFFF3E0),
      },
    ];

    return BotanicalHeaderDecoration(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.mainText, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'Choose Your Goal',
            style: TextStyle(
              color: AppColors.mainText,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Your Goal',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.mainText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select the area you want to improve',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 20),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: goals.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final isSelected = provider.currentObstacle.title == goal['title'];

                  return GestureDetector(
                    onTap: () {
                      final match = JourneyData.obstacles.firstWhere(
                        (o) => o.title.contains(goal['title'].toString().split(' ').first),
                        orElse: () => JourneyData.obstacles.first,
                      );
                      provider.selectObstacle(match);
                      if (onObstacleSelected != null) {
                        onObstacleSelected!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.cardShadow,
                        border: Border.all(
                          color: isSelected ? AppColors.primaryCoral : AppColors.cardBorder,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: goal['bgColor'] as Color,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              goal['icon'] as IconData,
                              color: goal['color'] as Color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal['title'],
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mainText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  goal['subtitle'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.secondaryText,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
