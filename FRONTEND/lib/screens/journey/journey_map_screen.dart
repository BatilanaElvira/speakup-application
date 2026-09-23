import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/journey.dart';
import '../../providers/app_provider.dart';
import '../../widgets/botanical_header.dart';
import '../analysis/past_analysis_history_screen.dart';
import '../practice/practice_studio_screen.dart';
import '../practice/topic_selection_screen.dart';
import 'obstacle_selector_screen.dart';

class JourneyMapScreen extends StatelessWidget {
  const JourneyMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final obstacle = provider.currentObstacle;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate dynamic progress
    int totalNodesCount = 0;
    int completedNodesCount = 0;
    for (final stage in obstacle.stages) {
      for (final node in stage.nodes) {
        totalNodesCount++;
        if (provider.completedNodeIds.contains(node.id)) {
          completedNodesCount++;
        }
      }
    }
    final progressPercent = totalNodesCount > 0 ? (completedNodesCount / totalNodesCount) : 0.35;

    return BotanicalHeaderDecoration(
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D0B26) : AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: obstacle.themeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: obstacle.themeColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${obstacle.title.toUpperCase()} ROADMAP',
              style: TextStyle(
                color: obstacle.themeColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.tune_rounded, color: isDark ? Colors.white : AppColors.secondaryText),
              tooltip: 'Switch Speaking Obstacle',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ObstacleSelectorScreen()),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Goal Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161344) : AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: obstacle.themeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          obstacle.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overcome ${obstacle.title}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : AppColors.mainText,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              obstacle.subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF9E9AC2) : AppColors.secondaryText,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Roadmap Progress Bar Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161344) : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.military_tech_rounded, size: 18, color: AppColors.secondaryTeal),
                              const SizedBox(width: 6),
                              Text(
                                'Overall Journey Progress',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.mainText,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${(progressPercent * 100).toInt()}% ($completedNodesCount / $totalNodesCount)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryTeal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          minHeight: 8,
                          backgroundColor: isDark ? const Color(0xFF1B164C) : AppColors.surfaceLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryTeal),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ROADMAP EXERCISES & STAGES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF9E9AC2) : AppColors.secondaryText,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Text(
                      'Tap to Review or Redo',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryCoral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stages & Exercises List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: obstacle.stages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final stage = obstacle.stages[index];
                    final allStageNodesCompleted = stage.nodes.every((n) => provider.completedNodeIds.contains(n.id));
                    final isStageActive = !allStageNodesCompleted && (index == 0 || obstacle.stages[index - 1].nodes.any((n) => provider.completedNodeIds.contains(n.id)));

                    return Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF161344) : AppColors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppColors.cardShadow,
                        border: Border.all(
                          color: isStageActive
                              ? AppColors.primaryCoral.withValues(alpha: 0.5)
                              : (isDark ? const Color(0xFF2B246A) : AppColors.cardBorder),
                          width: isStageActive ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stage Header
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: allStageNodesCompleted
                                        ? const Color(0xFF2BB7A9).withValues(alpha: 0.15)
                                        : isStageActive
                                            ? AppColors.primaryCoral.withValues(alpha: 0.15)
                                            : (isDark ? const Color(0xFF1F1A54) : AppColors.surfaceLight),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    stage.environmentEmoji,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Stage ${stage.stageNumber}: ${stage.title}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : AppColors.mainText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Environment: ${stage.environmentName}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? const Color(0xFF9E9AC2) : AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (allStageNodesCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2BB7A9).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'COMPLETED',
                                      style: TextStyle(
                                        color: Color(0xFF2BB7A9),
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else if (isStageActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryCoral.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'IN PROGRESS',
                                      style: TextStyle(
                                        color: AppColors.primaryCoral,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const Divider(height: 1),

                          // Node / Exercise Items
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: stage.nodes.length,
                            separatorBuilder: (context, i) => Divider(
                              color: isDark ? const Color(0xFF231D5E) : AppColors.cardBorder,
                              height: 1,
                            ),
                            itemBuilder: (context, nodeIdx) {
                              final node = stage.nodes[nodeIdx];
                              final isNodeDone = provider.completedNodeIds.contains(node.id);

                              return InkWell(
                                onTap: () => _openNodeInteractionModal(context, provider, node, stage, isNodeDone),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isNodeDone
                                            ? Icons.check_circle_rounded
                                            : Icons.play_circle_outline_rounded,
                                        color: isNodeDone ? AppColors.secondaryTeal : (isStageActive ? AppColors.primaryCoral : Colors.grey),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              node.title,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? Colors.white : AppColors.mainText,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${node.durationSeconds}s duration • +${node.xpReward} XP • ${node.difficulty}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? const Color(0xFF9E9AC2) : AppColors.secondaryText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isNodeDone
                                              ? (isDark ? const Color(0xFF1E1752) : const Color(0xFFEFF7F4))
                                              : (isDark ? const Color(0xFF1E1752) : const Color(0xFFFFECE8)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isNodeDone ? 'REDO / REVIEW' : 'START',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isNodeDone ? AppColors.secondaryTeal : AppColors.primaryCoral,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Primary Action Button: Start Next Uncompleted Exercise
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.coralGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.glowShadow(AppColors.primaryCoral),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TopicSelectionScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Practice Recommended Topic',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Interactive Modal for Completed or In-Progress Exercise
  void _openNodeInteractionModal(
    BuildContext context,
    AppProvider provider,
    JourneyNode node,
    JourneyStage stage,
    bool isCompleted,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161344) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF2BB7A9).withValues(alpha: 0.15)
                          : AppColors.primaryCoral.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle_rounded : Icons.fitness_center_rounded,
                      color: isCompleted ? const Color(0xFF2BB7A9) : AppColors.primaryCoral,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.mainText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCompleted
                              ? 'Status: COMPLETED (Recorded in past speech evaluations)'
                              : 'Status: READY TO PRACTICE',
                          style: TextStyle(
                            fontSize: 12,
                            color: isCompleted ? AppColors.secondaryTeal : AppColors.primaryCoral,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Situation Prompt Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B164C) : AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SPEECH SITUATION PROMPT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF9E9AC2) : AppColors.secondaryText,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      node.situationPrompt,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.mainText,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons: Redo / Practice & Review
              Row(
                children: [
                  if (isCompleted)
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.history_edu_rounded, size: 18),
                        label: const Text('Review Past Results', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFF9E8EFF) : AppColors.primaryPurple,
                          side: BorderSide(color: isDark ? const Color(0xFF9E8EFF) : AppColors.primaryPurple),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PastAnalysisHistoryScreen()),
                          );
                        },
                      ),
                    ),
                  if (isCompleted) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(isCompleted ? Icons.replay_rounded : Icons.mic_rounded, size: 18),
                      label: Text(
                        isCompleted ? 'Redo Exercise' : 'Start Practice',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCoral,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        provider.setTopic(node.situationPrompt);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PracticeStudioScreen(
                              initialTopic: node.situationPrompt,
                              nodeId: node.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
