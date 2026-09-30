import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../services/crowd_audio_service.dart';
import '../../services/speech_recognition_service.dart';
import '../../widgets/camera_feed/camera_feed_widget.dart';
import '../../widgets/simulated_environment_backdrop.dart';
import '../analysis/analysis_report_screen.dart';
import 'evaluator_oral_qa_screen.dart';

class VideoRecordingStudioScreen extends StatefulWidget {
  final String? nodeId;

  const VideoRecordingStudioScreen({super.key, this.nodeId});

  @override
  State<VideoRecordingStudioScreen> createState() => _VideoRecordingStudioScreenState();
}

class _VideoRecordingStudioScreenState extends State<VideoRecordingStudioScreen> with SingleTickerProviderStateMixin {
  static const int maxPracticeSeconds = 15 * 60; // 15 minutes limit (900 seconds)

  Timer? _timer;
  Timer? _crowdReactionTimer;
  int _seconds = 0; // Starts from 00:00:00
  bool _isRecording = false;
  bool _isPaused = false;
  bool _showGridLines = true;
  bool _isFrontCamera = true;
  bool _isAnalyzing = false;
  bool _hasReached15MinCap = false;

  // Real-time Speech-to-Text captured from the speaker's microphone
  String _liveTranscript = '';
  String _liveSubtitle = '';

  // AI Simulated Crowd Reactions
  String _currentReaction = 'Audience is listening attentively...';
  String _currentReactionEmoji = '👀';
  int _audienceEngagement = 94;

  final List<Map<String, dynamic>> _reactionPool = [
    {
      'emoji': '👏',
      'label': 'Enthusiastic applause ripples through the room',
      'engagement': 98,
      'sound': 'applause',
    },
    {
      'emoji': '🤫',
      'label': 'Enraptured silence — every eye is fixed on you',
      'engagement': 95,
      'sound': 'silence',
    },
    {
      'emoji': '💬',
      'label': 'Low murmurs of agreement throughout the audience',
      'engagement': 92,
      'sound': 'murmur',
    },
    {
      'emoji': '👍',
      'label': 'Key stakeholders and panel nod along approvingly',
      'engagement': 96,
      'sound': 'nod',
    },
    {
      'emoji': '📝',
      'label': 'Panelists are taking notes on your main argument',
      'engagement': 93,
      'sound': 'silence',
    },
    {
      'emoji': '✨',
      'label': 'Strong vocal hook — 300 listeners leaning in',
      'engagement': 99,
      'sound': 'applause',
    },
  ];

  int _reactionIndex = 0;

  @override
  void dispose() {
    SpeechRecognitionService.stopListening();
    CrowdAudioService.stopAmbientNoise();
    _timer?.cancel();
    _crowdReactionTimer?.cancel();
    super.dispose();
  }

  void _playCrowdSound(String soundType) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (!provider.isSimulatedEnvironmentEnabled || !provider.enableAudienceReactions) return;
    final vol = provider.audioVolume;
    
    if (soundType == 'applause') {
      CrowdAudioService.playApplause(vol);
    } else if (soundType == 'murmur') {
      CrowdAudioService.playMurmur(vol);
    } else if (soundType == 'silence') {
      CrowdAudioService.playSilenceChime(vol);
    } else if (soundType == 'nod' || soundType == 'nodding') {
      CrowdAudioService.playNodMimic(vol);
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
      _hasReached15MinCap = false;
    });

    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.isSimulatedEnvironmentEnabled && provider.enableAmbientAudio) {
      CrowdAudioService.startAmbientNoise(provider.audioVolume);
    }

    // Start live speech recognition to listen to the user's real speech
    SpeechRecognitionService.startListening(
      onResult: (text, isFinal) {
        if (mounted) {
          setState(() {
            _liveTranscript = text;
            final words = text.split(' ');
            _liveSubtitle = words.length > 7 ? words.sublist(words.length - 7).join(' ') : text;
          });
        }
      },
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _seconds++;
        });

        // 15-Minute Session Cap
        if (_seconds >= maxPracticeSeconds) {
          _onTimeLimitReached();
        }
      }
    });

    // Play opening audience attention chime / murmur
    _playCrowdSound('murmur');

    // Rotate simulated crowd reactions every 5 seconds
    _crowdReactionTimer?.cancel();
    _crowdReactionTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isRecording && !_isPaused && mounted) {
        setState(() {
          _reactionIndex = (_reactionIndex + 1) % _reactionPool.length;
          _currentReaction = _reactionPool[_reactionIndex]['label'];
          _currentReactionEmoji = _reactionPool[_reactionIndex]['emoji'];
          _audienceEngagement = _reactionPool[_reactionIndex]['engagement'];
        });
        _playCrowdSound(_reactionPool[_reactionIndex]['sound']);
      }
    });
  }

  void _triggerCrowdReaction(String emoji, String text, int engagement, [String sound = 'applause']) {
    if (!_isRecording) return;
    setState(() {
      _currentReactionEmoji = emoji;
      _currentReaction = text;
      _audienceEngagement = engagement;
    });
    _playCrowdSound(sound);
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _onTimeLimitReached() {
    _timer?.cancel();
    _crowdReactionTimer?.cancel();
    CrowdAudioService.stopAmbientNoise();
    final captured = SpeechRecognitionService.stopListening();
    if (captured.isNotEmpty) {
      _liveTranscript = captured;
    }
    setState(() {
      _isPaused = true;
      _hasReached15MinCap = true;
    });
    _showSubmitOrRetakeSheet();
  }

  void _onStopPressed() {
    _timer?.cancel();
    _crowdReactionTimer?.cancel();
    CrowdAudioService.stopAmbientNoise();
    final captured = SpeechRecognitionService.stopListening();
    if (captured.isNotEmpty) {
      _liveTranscript = captured;
    }
    setState(() {
      _isPaused = true;
    });
    _showSubmitOrRetakeSheet();
  }

  void _retakePractice() {
    SpeechRecognitionService.stopListening();
    CrowdAudioService.stopAmbientNoise();
    _timer?.cancel();
    _crowdReactionTimer?.cancel();

    setState(() {
      _seconds = 0;
      _liveTranscript = '';
      _liveSubtitle = '';
      _isPaused = false;
      _hasReached15MinCap = false;
      _isRecording = false;
    });

    _startRecording();
  }

  Future<void> _submitPractice() async {
    CrowdAudioService.stopAmbientNoise();
    SpeechRecognitionService.stopListening();
    _timer?.cancel();
    _crowdReactionTimer?.cancel();

    setState(() {
      _isAnalyzing = true;
    });

    final provider = Provider.of<AppProvider>(context, listen: false);

    // Call live Gemini speech evaluation with the actual live transcript
    final result = await provider.stopRecordingAndAnalyzeDirectly(
      durationSeconds: _seconds > 0 ? _seconds : 45,
      nodeId: widget.nodeId,
      customTranscript: _liveTranscript.trim().isNotEmpty ? _liveTranscript.trim() : null,
    );

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
    });

    if (result == null) return;

    // If evaluator is Stage Evaluator: Monologue presentation (no oral Q&A)
    final isStage = provider.selectedEvaluator.id == 'stage';
    if (isStage) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AnalysisReportScreen(result: result)),
      );
    } else {
      // Non-stage evaluator: Route directly to the Evaluator Oral Q&A session!
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EvaluatorOralQAScreen(sessionResult: result),
        ),
      );
    }
  }

  void _showSubmitOrRetakeSheet() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final eval = provider.selectedEvaluator;
    final isStage = eval.id == 'stage';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Header & Timer pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _hasReached15MinCap
                            ? AppColors.primaryCoral.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _hasReached15MinCap ? AppColors.primaryCoral : Colors.white24,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _hasReached15MinCap ? Icons.timer_off_rounded : Icons.timer_rounded,
                            color: _hasReached15MinCap ? AppColors.primaryCoral : Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _hasReached15MinCap
                                ? '15:00 MAX TIME REACHED'
                                : '${_formatTimer(_seconds)} RECORDED',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text(
                  _hasReached15MinCap ? 'Practice Session Completed!' : 'Practice Paused',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  isStage
                      ? 'Submit your keynote speech to get your AI feedback report, or retake the practice.'
                      : 'Submit to proceed to ${eval.name}\'s oral Q&A follow-up session, or retake the practice.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 16),

                // Live Transcript Preview Box
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 110),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.record_voice_over_rounded, color: AppColors.secondaryTeal, size: 14),
                            const SizedBox(width: 6),
                            const Text(
                              'TRANSCRIPTION DETECTED:',
                              style: TextStyle(
                                color: AppColors.secondaryTeal,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _liveTranscript.trim().isNotEmpty
                              ? '“${_liveTranscript.trim()}”'
                              : 'No spoken words captured yet. You can retake and speak into your microphone, or submit for baseline evaluation.',
                          style: TextStyle(
                            color: _liveTranscript.trim().isNotEmpty ? Colors.white : Colors.white38,
                            fontSize: 12.5,
                            fontStyle: _liveTranscript.trim().isNotEmpty ? FontStyle.normal : FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 1. Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _submitPractice();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCoral,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      isStage
                          ? 'Submit for Evaluation Report →'
                          : 'Submit & Start Oral Q&A with ${eval.name} →',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 2. Retake Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _retakePractice();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Retake Practice (Start Fresh)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimer(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    final s = sec % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final env = provider.selectedEnvironment;
    final isSimEnabled = provider.isSimulatedEnvironmentEnabled;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Live Camera Feed from User Device
            Positioned.fill(
              child: CameraFeedWidget(isFrontCamera: _isFrontCamera),
            ),

            // 2. Dynamic Simulated Environment Visual Backdrop Overlay
            if (isSimEnabled)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.85,
                  child: SimulatedEnvironmentBackdrop(
                    environment: env,
                    isRecording: _isRecording,
                    isEnabled: isSimEnabled,
                  ),
                ),
              ),

            // 2. Camera Grid Lines Overlay (Optional toggle)
            if (_showGridLines)
              Positioned.fill(
                child: IgnorePointer(
                  child: Column(
                    children: [
                      Expanded(child: Container()),
                      const Divider(color: Colors.white12, height: 1),
                      Expanded(child: Container()),
                      const Divider(color: Colors.white12, height: 1),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ),

            // 3. Top Status & Navigation Bar
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),

                  // Timer Pill (00:00:00) with Live Red Pulse
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isRecording ? AppColors.primaryCoral : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording ? AppColors.primaryCoral : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimer(_seconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Camera options (Flip & Grid toggle)
                  Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: Icon(
                            _showGridLines ? Icons.grid_on_rounded : Icons.grid_off_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showGridLines = !_showGridLines;
                          });
                        },
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.cameraswitch_rounded, color: Colors.white, size: 18),
                        ),
                        onPressed: () {
                          setState(() {
                            _isFrontCamera = !_isFrontCamera;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 4. Floating Simulated Environment Badge & Evaluator Persona
            if (isSimEnabled)
              Positioned(
                top: 70,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(env.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            env.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Evaluator Persona Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(provider.selectedEvaluator.icon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            provider.selectedEvaluator.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // 5. AI Simulated Crowd Reaction Floating HUD (When Recording)
            if (_isRecording && isSimEnabled)
              Positioned(
                top: 115,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.85),
                            const Color(0xFF1E1B4B).withValues(alpha: 0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.secondaryTeal.withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondaryTeal.withValues(alpha: 0.2),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(_currentReactionEmoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentReaction,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Audience Engagement: $_audienceEngagement% • Noise: ${env.noiseLevel}',
                                  style: TextStyle(
                                    color: AppColors.secondaryTeal.withValues(alpha: 0.9),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Manual Crowd Reaction Trigger Pills (Interactive Immersion)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCrowdActionPill('👏 Applause', () {
                            _triggerCrowdReaction('👏', 'Resounding applause throughout the auditorium!', 99, 'applause');
                          }),
                          const SizedBox(width: 8),
                          _buildCrowdActionPill('🤫 Silence', () {
                            _triggerCrowdReaction('🤫', 'Intense silence — audience hangs on every word.', 96, 'silence');
                          }),
                          const SizedBox(width: 8),
                          _buildCrowdActionPill('💬 Murmurs', () {
                            _triggerCrowdReaction('💬', 'Murmurs of agreement and lively interest.', 93, 'murmur');
                          }),
                          const SizedBox(width: 8),
                          _buildCrowdActionPill('👍 Nodding', () {
                            _triggerCrowdReaction('👍', 'Panelists nod along with your thesis points.', 97, 'murmur');
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // 6. Analyzing Overlay Modal (When Gemini AI is processing)
            if (_isAnalyzing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.85),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 56,
                          height: 56,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryCoral,
                            strokeWidth: 4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '🤖 Gemini AI Speech Evaluation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Analyzing vocal clarity, pace, confidence, and weaknesses...',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 6.5 Live Subtitle / Speech Feedback Pill (Shows what speaker is saying in real-time)
            if (_isRecording && _liveSubtitle.isNotEmpty)
              Positioned(
                bottom: 126,
                left: 20,
                right: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondaryTeal.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryTeal.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mic_rounded, color: AppColors.secondaryTeal, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '“$_liveSubtitle”',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 7. Bottom Recording Controls
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  if (!_isRecording) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Ready to practice in ${isSimEnabled ? env.title : "Clean Studio"} • 15 Min Limit',
                        style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _startRecording,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryCoral,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryCoral.withValues(alpha: 0.6),
                              blurRadius: 24,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 36),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Start Recording', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Pause / Resume Button
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              iconSize: 32,
                              icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: Icon(
                                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: _togglePause,
                            ),
                            Text(
                              _isPaused ? 'Resume' : 'Pause',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),

                        // Stop & Review Button (Opens Submit or Retake Modal)
                        GestureDetector(
                          onTap: _onStopPressed,
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3.5),
                              color: AppColors.primaryCoral,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryCoral.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),

                        // Retake / Reset Button
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              iconSize: 32,
                              icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.refresh_rounded, color: Colors.white),
                              ),
                              onPressed: _retakePractice,
                            ),
                            const Text('Retake', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrowdActionPill(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

}
