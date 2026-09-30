import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/practice_session.dart';
import '../../providers/app_provider.dart';
import '../../widgets/botanical_header.dart';

class AnalysisReportScreen extends StatefulWidget {
  final PracticeSessionResult? result;

  const AnalysisReportScreen({super.key, this.result});

  @override
  State<AnalysisReportScreen> createState() => _AnalysisReportScreenState();
}

class _AnalysisReportScreenState extends State<AnalysisReportScreen> {
  bool _isAnalyzing = true;
  int _analysisProgress = 25;
  Timer? _analysisTimer;

  @override
  void initState() {
    super.initState();
    // Simulate AI speech analysis steps up to 100%
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (_analysisProgress < 100) {
        setState(() {
          _analysisProgress += 25;
        });
      } else {
        timer.cancel();
        setState(() {
          _isAnalyzing = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final session = widget.result ?? provider.latestResult ?? PracticeSessionResult.mockHistory.first;

    return BotanicalHeaderDecoration(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.mainText, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryCoral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _isAnalyzing ? 'Analyzing Speech with AI' : 'Speech Analysis Report',
              style: const TextStyle(
                color: AppColors.primaryCoral,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _isAnalyzing
                ? _buildAnalyzingView()
                : _buildFeedbackOverviewView(session, provider),
          ),
        ),
      ),
    );
  }

  // Screen 13: Analyzing Screen
  Widget _buildAnalyzingView() {
    return Center(
      key: const ValueKey('analyzing_view'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Analyzing Your Speech',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.mainText,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Gemini AI is assessing your fluency, tone, and confidence...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 36),

            // Progress Ring Gauge
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: AppColors.cardShadow,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_analysisProgress%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryCoral,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'AI Processing',
                    style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Checklist
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildCheckStep('Transcribing audio', _analysisProgress >= 25),
                  const SizedBox(height: 10),
                  _buildCheckStep('Assessing speech pacing & fillers', _analysisProgress >= 50),
                  const SizedBox(height: 10),
                  _buildCheckStep('Evaluating clarity & argument structure', _analysisProgress >= 75),
                  const SizedBox(height: 10),
                  _buildCheckStep('Generating actionable coaching recommendations', _analysisProgress >= 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckStep(String label, bool isDone) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: isDone ? AppColors.sageGreen : AppColors.secondaryText,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
              color: isDone ? AppColors.mainText : AppColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }

  // Screen 14: Dynamic Feedback Overview
  Widget _buildFeedbackOverviewView(PracticeSessionResult session, AppProvider provider) {
    final firstName = provider.userName.split(' ').first;
    final score = session.overallScore;
    final scoreBadgeColor = score >= 85
        ? AppColors.sageGreen
        : score >= 70
            ? AppColors.primaryCoral
            : AppColors.warningAmber;
    final scoreBadgeBg = score >= 85
        ? AppColors.sageLightBg
        : score >= 70
            ? AppColors.primaryCoral.withValues(alpha: 0.12)
            : const Color(0xFFFEF3C7);
    final scoreLabel = score >= 85
        ? 'Excellent 🌟'
        : score >= 75
            ? 'Great Job 👍'
            : score >= 60
                ? 'Good Effort 💡'
                : 'Needs Work 🎯';

    return SingleChildScrollView(
      key: const ValueKey('feedback_overview'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Well done, $firstName! 🎉',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.mainText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Here is your AI evaluation by ${session.evaluatorName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryCoral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: AppColors.primaryCoral),
                    const SizedBox(width: 4),
                    Text(
                      '+50 XP',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryCoral,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Overall Score Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppColors.cardShadow,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                const Text(
                  'OVERALL PERFORMANCE SCORE',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.0,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: scoreBadgeColor,
                      ),
                    ),
                    const Text(
                      ' /100',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: scoreBadgeBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    scoreLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: scoreBadgeColor,
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                const Divider(color: AppColors.cardBorder),
                const SizedBox(height: 14),

                // Dynamic Metric Pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricPill('Clarity', '${session.clarityScore}%'),
                    _buildMetricPill('Confidence', '${session.confidenceScore}%'),
                    _buildMetricPill('Pacing', '${session.paceScore} WPM'),
                    _buildMetricPill('Fillers', '${session.fillerWordCount}'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Top Strengths
          const Text(
            '🌟 Top Strengths Identified',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.cardShadow,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: session.strengths.isNotEmpty
                  ? session.strengths
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildStrengthItem(s),
                          ))
                      .toList()
                  : [
                      _buildStrengthItem('Clear articulation and audible voice projection'),
                      _buildStrengthItem('Maintained steady momentum through arguments'),
                    ],
            ),
          ),

          const SizedBox(height: 20),

          // Areas for Improvement
          if (session.weaknesses.isNotEmpty) ...[
            const Text(
              '🎯 Areas for Growth',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: session.weaknesses
                    .map((w) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildWeaknessItem(w),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Actionable Coach Advice
          if (session.howToImprove.isNotEmpty) ...[
            const Text(
              '💡 Coach Action Plan',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.cardShadow,
                border: Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.psychology_alt_rounded, color: AppColors.primaryCoral, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      session.howToImprove,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: AppColors.mainText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 4. Evaluator Follow-Up Q&A (Analyzes speech content; omitted for stage monologues)
          if (session.evaluatorName.toLowerCase().contains('stage') ||
              session.evaluatorName.toLowerCase().contains('ted') ||
              session.evaluatorName.toLowerCase().contains('keynote')) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF1F3),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primaryCoral.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Text('🎤', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keynote Stage Monologue',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'As a TED-style keynote presentation, no mid-speech evaluator interruptions or cross-examination questions are permitted.',
                          style: TextStyle(fontSize: 11.5, color: AppColors.mainText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (session.audienceQuestions.isNotEmpty) ...[
            Text(
              '❓ ${session.evaluatorName} Follow-Up Questions',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            ...session.audienceQuestions.map((q) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              session.evaluatorName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.primaryBlue),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        q.question,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainText,
                          height: 1.4,
                        ),
                      ),
                      if (q.speakerAnswer.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Recommended Defense / Model Answer:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                q.speakerAnswer,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.mainText,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                )),
            const SizedBox(height: 14),
          ],

          // Recommended Books
          if (session.recommendedBooks.isNotEmpty) ...[
            const Text(
              '📚 Recommended Reading',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            ...session.recommendedBooks.map((book) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.sageLightBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.menu_book_rounded, color: AppColors.sageGreen, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.mainText),
                            ),
                            Text(
                              'by ${book.author}',
                              style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
          ],

          // Return Home & Finish Buttons
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCoral,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Complete Session & Return',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.secondaryText, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.mainText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.sageGreen, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.mainText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeaknessItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primaryCoral, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.mainText,
            ),
          ),
        ),
      ],
    );
  }
}
