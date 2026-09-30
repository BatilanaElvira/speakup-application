import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../services/crowd_audio_service.dart';
import '../../services/speech_recognition_service.dart';
import '../../widgets/simulated_environment_backdrop.dart';
import '../analysis/analysis_report_screen.dart';
import 'evaluator_oral_qa_screen.dart';

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
  static const int maxPracticeSeconds = 15 * 60; // 15-minute cap (900 seconds)

  late AnimationController _pulseController;
  Timer? _timer;
  Timer? _crowdReactionTimer;
  int _seconds = 0; // Timer starts at 00:00:00
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isAnalyzing = false;
  bool _hasReached15MinCap = false;

  // Real-time Speech-to-Text captured from the speaker
  String _liveTranscript = '';
  String _liveSubtitle = '';

  // AI Simulated Crowd Reactions
  String _currentReaction = 'Audience is seated and waiting for your opening hook...';
  String _currentReactionEmoji = '👀';
  int _audienceEngagement = 92;
  int _reactionIndex = 0;

  final List<Map<String, dynamic>> _reactionPool = [
    {
      'emoji': '👏',
      'label': 'Enthusiastic applause ripples through the room!',
      'engagement': 98,
      'type': 'applause'
    },
    {
      'emoji': '🤫',
      'label': 'Enraptured silence — every eye is fixed on you',
      'engagement': 95,
      'type': 'silence'
    },
    {
      'emoji': '💬',
      'label': 'Low murmurs of agreement throughout the audience',
      'engagement': 93,
      'type': 'murmur'
    },
    {
      'emoji': '👍',
      'label': 'Key stakeholders and panel nod along approvingly',
      'engagement': 96,
      'type': 'nod'
    },
    {
      'emoji': '📝',
      'label': 'Panelists are taking notes on your main argument',
      'engagement': 94,
      'type': 'silence'
    },
    {
      'emoji': '✨',
      'label': 'Captivating projection — 300 listeners leaning in',
      'engagement': 99,
      'type': 'applause'
    },
  ];

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
    SpeechRecognitionService.stopListening();
    CrowdAudioService.stopAmbientNoise();
    _pulseController.dispose();
    _timer?.cancel();
    _crowdReactionTimer?.cancel();
    super.dispose();
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

    // Start live speech-to-text to capture actual speech
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

    _pulseController.repeat(reverse: true);
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

    // Rotate simulated crowd reaction every 6 seconds when simulation enabled
    _crowdReactionTimer?.cancel();
    _crowdReactionTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_isRecording && !_isPaused && mounted) {
        if (provider.isSimulatedEnvironmentEnabled && provider.enableAudienceReactions) {
          _reactionIndex = (_reactionIndex + 1) % _reactionPool.length;
          final nextReaction = _reactionPool[_reactionIndex];
          setState(() {
            _currentReaction = nextReaction['label'];
            _currentReactionEmoji = nextReaction['emoji'];
            _audienceEngagement = nextReaction['engagement'];
          });

          // Play audio effect if ambient audio is enabled
          if (provider.enableAmbientAudio) {
            final vol = provider.audioVolume;
            if (nextReaction['type'] == 'applause') {
              CrowdAudioService.playApplause(vol);
            } else if (nextReaction['type'] == 'murmur') {
              CrowdAudioService.playMurmur(vol);
            } else if (nextReaction['type'] == 'silence') {
              CrowdAudioService.playSilenceChime(vol);
            } else if (nextReaction['type'] == 'nod' || nextReaction['type'] == 'nodding') {
              CrowdAudioService.playNodMimic(vol);
            }
          }
        }
      }
    });
  }

  void _triggerCrowdReaction(String emoji, String text, int engagement, String soundType) {
    if (!_isRecording) return;
    final provider = Provider.of<AppProvider>(context, listen: false);
    setState(() {
      _currentReactionEmoji = emoji;
      _currentReaction = text;
      _audienceEngagement = engagement;
    });

    if (provider.enableAmbientAudio) {
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
    final result = await provider.stopRecordingAndAnalyzeDirectly(
      durationSeconds: _seconds > 0 ? _seconds : 45,
      nodeTitle: widget.topic,
      customTranscript: _liveTranscript.trim().isNotEmpty ? _liveTranscript.trim() : null,
    );

    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
    });

    if (result == null) return;

    final isStage = provider.selectedEvaluator.id == 'stage';
    if (isStage) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AnalysisReportScreen(result: result)),
      );
    } else {
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
                      ? 'Submit your speech to receive your AI score and diagnostic feedback, or retake the practice.'
                      : 'Submit to proceed to ${eval.name}\'s oral Q&A session, or retake the practice.',
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final evalName = widget.evaluatorName ?? provider.selectedEvaluator.name;
    final evalIcon = widget.evaluatorIcon ?? provider.selectedEvaluator.icon;
    final isSimEnabled = provider.isSimulatedEnvironmentEnabled;
    final env = provider.selectedEnvironment;
    final topic = widget.topic ?? provider.currentTopic;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
          // 1. Dynamic Simulated Environment Visual Backdrop
          Positioned.fill(
            child: SimulatedEnvironmentBackdrop(
              environment: env,
              isRecording: _isRecording,
              isEnabled: isSimEnabled,
            ),
          ),

          // 2. Main Practice Studio Controls & Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Top Navigation & Environment Status Bar
                  Row(
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

                      // Environment Context Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSimEnabled
                              ? const Color(0xFF1E1B4B).withValues(alpha: 0.85)
                              : Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSimEnabled ? AppColors.secondaryTeal : Colors.white24,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(isSimEnabled ? env.emoji : '⚡', style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              isSimEnabled ? env.title : 'Clean Studio Mode',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            if (isSimEnabled && provider.enableAmbientAudio) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.volume_up_rounded, color: AppColors.secondaryTeal, size: 13),
                            ],
                          ],
                        ),
                      ),

                      // Evaluator Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(evalIcon, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(
                              evalName.split(' ').first,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Selected Topic Banner Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PRACTICE TOPIC',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          topic,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // AI Live Audience Reaction Banner (Crowd Mimic Engine)
                  if (isSimEnabled) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.85),
                            const Color(0xFF1E1B4B).withValues(alpha: 0.85),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _isRecording ? AppColors.secondaryTeal.withValues(alpha: 0.6) : Colors.white24,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? AppColors.secondaryTeal : Colors.black).withValues(alpha: 0.25),
                            blurRadius: 12,
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
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'AUDIENCE SIMULATOR (${env.audienceType.toUpperCase()})',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        color: AppColors.secondaryTeal,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryTeal.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$_audienceEngagement% ENGAGED',
                                        style: const TextStyle(
                                          color: AppColors.secondaryTeal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentReaction,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
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

                    // Interactive Audience Reaction Cues (Speaker practice triggers)
                    if (_isRecording)
                      SizedBox(
                        height: 30,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildCrowdActionPill('👏 Applause', () {
                              _triggerCrowdReaction(
                                '👏',
                                'Loud applause ripples across the hall!',
                                98,
                                'applause',
                              );
                            }),
                            const SizedBox(width: 8),
                            _buildCrowdActionPill('💬 Murmurs', () {
                              _triggerCrowdReaction(
                                '💬',
                                'Subtle murmurs of agreement among listeners',
                                93,
                                'murmur',
                              );
                            }),
                            const SizedBox(width: 8),
                            _buildCrowdActionPill('🤫 Silence', () {
                              _triggerCrowdReaction(
                                '🤫',
                                'Dead silence — auditorium waiting on your next phrase',
                                95,
                                'silence',
                              );
                            }),
                            const SizedBox(width: 8),
                            _buildCrowdActionPill('👍 Nodding', () {
                              _triggerCrowdReaction(
                                '👍',
                                'Audience members nod vigorously in approval',
                                97,
                                'silence',
                              );
                            }),
                          ],
                        ),
                      ),
                  ],

                  const Spacer(),

                  // Timer display starting from 00:00:00 with red pulse
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isRecording ? AppColors.primaryCoral : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording && !_isPaused ? AppColors.primaryCoral : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _formatTimer(_seconds),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    _isAnalyzing
                        ? 'Analyzing with Gemini AI...'
                        : (_isRecording
                            ? (_isPaused ? 'Paused' : 'Speaking live to simulated audience...')
                            : 'Tap mic to start practicing in this environment'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Center Microphone Button / Action Controls
                  if (!_isRecording) ...[
                    GestureDetector(
                      onTap: _startRecording,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryCoral.withValues(alpha: 0.15),
                                ),
                              ),
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryCoral,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryCoral.withValues(alpha: 0.6),
                                      blurRadius: 30,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.mic_rounded, color: Colors.white, size: 48),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'START RECORDING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ] else ...[
                    // 6.5 Live Subtitle / Spoken Feedback Pill
                    if (_isRecording && _liveSubtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.secondaryTeal.withValues(alpha: 0.5)),
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Pause / Resume
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              iconSize: 32,
                              icon: Container(
                                padding: const EdgeInsets.all(12),
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

                        // Finish & Review Button (Opens Submit or Retake Modal)
                        GestureDetector(
                          onTap: _isAnalyzing ? null : _onStopPressed,
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3.5),
                              color: AppColors.primaryCoral,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryCoral.withValues(alpha: 0.6),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: _isAnalyzing
                                ? const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                  )
                                : Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                          ),
                        ),

                        // Retake
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              iconSize: 32,
                              icon: Container(
                                padding: const EdgeInsets.all(12),
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
                    const SizedBox(height: 6),
                    const Text(
                      'TAP SQUARE TO FINISH & CHOOSE SUBMIT OR RETAKE',
                      style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrowdActionPill(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
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
