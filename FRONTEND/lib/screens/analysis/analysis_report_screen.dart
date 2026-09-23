import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/practice_session.dart';
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
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
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
              _isAnalyzing ? 'Analyzing Speech' : 'Speech Analysis Report',
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
            child: _isAnalyzing ? _buildAnalyzingView() : _buildFeedbackOverviewView(),
          ),
        ),
      ),
    );
  }

  // Screen 13: Analyzing Screen
  Widget _buildAnalyzingView() {
    return SingleChildScrollView(
      key: const ValueKey('analyzing_view'),
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
            'Please wait while AI evaluates your speech...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: 36),

          // 85% Progress Ring Gauge
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
                  'Progress',
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
                _buildCheckStep('Transcribing speech', _analysisProgress >= 25),
                const SizedBox(height: 10),
                _buildCheckStep('Analyzing content', _analysisProgress >= 50),
                const SizedBox(height: 10),
                _buildCheckStep('Evaluating delivery', _analysisProgress >= 75),
                const SizedBox(height: 10),
                _buildCheckStep('Generating feedback', _analysisProgress >= 100),
              ],
            ),
          ),
        ],
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
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            color: isDone ? AppColors.mainText : AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  // Screen 14: Feedback Overview
  Widget _buildFeedbackOverviewView() {
    return SingleChildScrollView(
      key: const ValueKey('feedback_overview'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Great job, Amina! 🎉',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.mainText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Here is your overall feedback',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: 20),

          // Overall Score Arch Gauge Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppColors.cardShadow,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                const Text(
                  'Overall Score',
                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      '78',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryCoral,
                      ),
                    ),
                    Text(
                      ' /100',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sageLightBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Good',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.sageGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: AppColors.cardBorder),
                const SizedBox(height: 16),

                // Metric pills row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricPill('Content', '80'),
                    _buildMetricPill('Delivery', '75'),
                    _buildMetricPill('Confidence', '82'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Top Strengths',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 10),

          // Strengths list
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.cardShadow,
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                _buildStrengthItem('Clear structure and organization'),
                const SizedBox(height: 10),
                _buildStrengthItem('Good pace and tone'),
                const SizedBox(height: 10),
                _buildStrengthItem('Engaging delivery'),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Coral Action Button
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
                'View Detailed Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
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
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.sageGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.mainText,
            ),
          ),
        ),
      ],
    );
  }
}
