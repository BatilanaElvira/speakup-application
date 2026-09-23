import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../analysis/analysis_report_screen.dart';

class InteractiveQAStudio extends StatefulWidget {
  final String? nodeId;
  final String? topic;
  final String? evaluatorName;
  final String? evaluatorIcon;

  const InteractiveQAStudio({
    super.key,
    this.nodeId,
    this.topic,
    this.evaluatorName,
    this.evaluatorIcon,
  });

  @override
  State<InteractiveQAStudio> createState() => _InteractiveQAStudioState();
}

typedef InteractiveQAStudioScreen = InteractiveQAStudio;

class _InteractiveQAStudioState extends State<InteractiveQAStudio> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _timer;
  int _seconds = 0; // Timer starts at 00:00:00
  bool _isRecording = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
    });

    _pulseController.repeat(reverse: true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  String _formatTimer(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    final s = sec % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _finishRecording() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AnalysisReportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final evalName = widget.evaluatorName ?? provider.selectedEvaluator.name;
    final evalIcon = widget.evaluatorIcon ?? provider.selectedEvaluator.icon;
    final isSimEnabled = provider.isSimulatedEnvironmentEnabled;
    final env = provider.selectedEnvironment;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryCoral.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$evalIcon $evalName Studio',
            style: const TextStyle(
              color: AppColors.primaryCoral,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Environment Simulation Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSimEnabled
                      ? AppColors.primaryBlue.withValues(alpha: 0.2)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSimEnabled
                        ? AppColors.primaryBlue.withValues(alpha: 0.5)
                        : Colors.white24,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isSimEnabled ? env.emoji : '⚡', style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      isSimEnabled ? 'Simulated: ${env.title}' : 'Clean Focus Mode',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isSimEnabled && provider.enableAmbientAudio) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.volume_up_rounded, color: AppColors.secondaryTeal, size: 14),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Timer display starting from 00:00:00
              Text(
                _formatTimer(_seconds),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isRecording ? (_isPaused ? 'Paused' : 'Recording...') : 'Tap mic to start recording',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // Pulsing Microphone Circle
              GestureDetector(
                onTap: !_isRecording ? _startRecording : null,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = _isRecording && !_isPaused ? 1.0 + (_pulseController.value * 0.15) : 1.0;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ripple 2
                        Container(
                          width: 220 * scale,
                          height: 220 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryCoral.withValues(alpha: _isRecording ? 0.08 : 0.04),
                          ),
                        ),
                        // Outer ripple 1
                        Container(
                          width: 180 * scale,
                          height: 180 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryCoral.withValues(alpha: _isRecording ? 0.18 : 0.08),
                          ),
                        ),
                        // Inner Circle Button
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryCoral,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryCoral.withValues(alpha: 0.6),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mic_rounded,
                            color: Colors.white,
                            size: 56,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const Spacer(),

              // Control Bar (Start / Pause / Stop)
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: !_isRecording
                    ? SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _startRecording,
                          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                          label: const Text(
                            'Start Recording',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryCoral,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                            elevation: 4,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pause / Resume Button
                          ElevatedButton.icon(
                            onPressed: _togglePause,
                            icon: Icon(_isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white),
                            label: Text(_isPaused ? 'Resume' : 'Pause'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Stop & Analyze Button
                          ElevatedButton.icon(
                            onPressed: _finishRecording,
                            icon: const Icon(Icons.stop_rounded, color: Colors.white),
                            label: const Text('Stop & Analyze'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryCoral,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
