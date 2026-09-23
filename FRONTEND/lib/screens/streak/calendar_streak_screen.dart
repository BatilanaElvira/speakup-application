import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_provider.dart';

class CalendarStreakScreen extends StatelessWidget {
  const CalendarStreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    final completedDates = provider.completedPracticeDaysInCurrentMonth;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AUTOMATIC STREAK TRACKER',
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
            // Streak Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.coralGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.glowShadow(AppColors.motivationCoral),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 44)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${provider.streakDays} DAY ACTIVE STREAK!',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'The system automatically ticks your streak every day you practice an exercise.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SEPTEMBER 2026',
                  style: TextStyle(
                    color: AppColors.mainText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '${completedDates.length} Days Practiced',
                  style: const TextStyle(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Calendar Grid Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.cardShadow,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  // Days of week header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _DayHeader('S'),
                      _DayHeader('M'),
                      _DayHeader('T'),
                      _DayHeader('W'),
                      _DayHeader('T'),
                      _DayHeader('F'),
                      _DayHeader('S'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 12),

                  // September 2026 Grid (Starts on Tuesday = offset 2, 30 days)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: 32, // 2 padding + 30 days
                    itemBuilder: (context, idx) {
                      if (idx < 2) {
                        return const SizedBox.shrink();
                      }
                      final dayNum = idx - 1;
                      final isPracticed = completedDates.contains(dayNum);
                      final isToday = dayNum == now.day;

                      return Container(
                        decoration: BoxDecoration(
                          color: isPracticed
                              ? AppColors.successGreen
                              : isToday
                                  ? AppColors.motivationCoral.withValues(alpha: 0.15)
                                  : AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isToday
                                ? AppColors.motivationCoral
                                : isPracticed
                                    ? AppColors.successGreen
                                    : AppColors.cardBorder,
                            width: isToday ? 2.0 : 1.0,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$dayNum',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isPracticed ? AppColors.white : AppColors.mainText,
                              ),
                            ),
                            if (isPracticed)
                              const Text('🔥', style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),


            const SizedBox(height: 24),
            const Text(
              'STREAK MILESTONES',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            _buildMilestoneRow('🔥 7-Day Streak Badge', 'Unlocked Aug 24', true),
            const SizedBox(height: 8),
            _buildMilestoneRow('⚡ 14-Day Streak Badge', 'Unlocked Aug 31', true),
            const SizedBox(height: 8),
            _buildMilestoneRow('🏆 30-Day Master Speaker Badge', 'In progress (14/30)', false),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneRow(String title, String status, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isUnlocked ? AppColors.warningAmber : AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.mainText),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUnlocked ? AppColors.warningAmber.withValues(alpha: 0.15) : AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: isUnlocked ? AppColors.warningAmber : AppColors.secondaryText,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String day;
  const _DayHeader(this.day);

  @override
  Widget build(BuildContext context) {
    return Text(
      day,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.secondaryText,
        fontSize: 13,
      ),
    );
  }
}
