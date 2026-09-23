import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/botanical_header.dart';
import '../practice/practice_studio_screen.dart';

class DailyBriefScreen extends StatelessWidget {
  const DailyBriefScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

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
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryCoral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Daily Brief Notification',
              style: TextStyle(
                color: AppColors.primaryCoral,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.coralGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.glowShadow(AppColors.primaryCoral),
                  ),
                  child: Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'DAILY AI KNOWLEDGE BRIEF',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'A 60-second bite-sized topic delivered fresh daily by AI to build your impromptu speaking habit.',
                              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Brief Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.sageLightBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'TODAY\'S BRIEF',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.sageGreen,
                              ),
                            ),
                          ),
                          const Text(
                            'September 1, 2026',
                            style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'The Psychology of First Impressions in Speaking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.mainText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Research shows audiences form their initial impression of a speaker within the first 7 seconds of taking the stage — driven primarily by posture, eye contact, and vocal warmth.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryText,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.cardBorder),
                      const SizedBox(height: 12),
                      const Text(
                        'Key Takeaways:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.mainText),
                      ),
                      const SizedBox(height: 8),
                      _buildBullet('Pause for 2 seconds before speaking your first word.'),
                      _buildBullet('Maintain open body language and clear eye contact.'),
                      _buildBullet('Use a warm, steady vocal pitch to project confidence.'),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Coral Button: Practice This Brief Now
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.setTopic('The Psychology of First Impressions in Speaking');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PracticeStudioScreen(
                            initialTopic: 'The Psychology of First Impressions in Speaking',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.mic_rounded, color: Colors.white),
                    label: const Text(
                      'Practice This Brief Now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCoral,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primaryCoral, fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.mainText)),
          ),
        ],
      ),
    );
  }
}
