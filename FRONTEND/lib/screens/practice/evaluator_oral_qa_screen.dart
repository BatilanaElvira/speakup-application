import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/practice_session.dart';
import '../../providers/app_provider.dart';
import '../../services/speech_recognition_service.dart';
import '../analysis/analysis_report_screen.dart';

class EvaluatorOralQAScreen extends StatefulWidget {
  final PracticeSessionResult sessionResult;

  const EvaluatorOralQAScreen({super.key, required this.sessionResult});

  @override
  State<EvaluatorOralQAScreen> createState() => _EvaluatorOralQAScreenState();
}

class _EvaluatorOralQAScreenState extends State<EvaluatorOralQAScreen> with SingleTickerProviderStateMixin {
  late PracticeSessionResult _session;
  int _currentQuestionIndex = 0;
  List<AudienceQuestion> _questions = [];

  bool _isEvaluatorSpeaking = false;
  bool _isUserListeningMic = false;
  String _liveUserSpokenAnswer = '';
  final TextEditingController _answerController = TextEditingController();

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _session = widget.sessionResult;
    _questions = List.from(_session.audienceQuestions);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // If there are no questions (or stage evaluator), prepare default questions based on evaluator logic
    if (_questions.isEmpty) {
      final isCoach = _session.evaluatorName.toLowerCase().contains('coach') ||
          _session.evaluatorName.toLowerCase().contains('story');
      if (isCoach) {
        _questions = [
          AudienceQuestion(
            question: 'Are you feeling nervous or afraid? I noticed a slight tremor in your voice when you introduced "${_session.topic}".',
            speakerAnswer: '',
          ),
          AudienceQuestion(
            question: 'Are you feeling sick or fatigued today? Your vocal projection dropped noticeably in the middle section.',
            speakerAnswer: '',
          ),
        ];
      } else {
        _questions = [
          AudienceQuestion(
            question: '${_session.evaluatorName} Follow-Up: In your speech on "${_session.topic}", what empirical evidence validates your core conclusion?',
            speakerAnswer: '',
          ),
          AudienceQuestion(
            question: 'How do you defend this strategy against competitive pushback or cost constraints?',
            speakerAnswer: '',
          ),
        ];
      }
    }

    // Speak the first evaluator question automatically after a short pause
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakCurrentQuestion();
    });
  }

  @override
  void dispose() {
    SpeechRecognitionService.stopSpeaking();
    SpeechRecognitionService.stopListening();
    _pulseController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _speakCurrentQuestion() {
    if (_questions.isEmpty) return;
    final questionText = _questions[_currentQuestionIndex].question;
    setState(() {
      _isEvaluatorSpeaking = true;
    });

    SpeechRecognitionService.speakText(questionText);

    // Estimate speaking duration: roughly 150 words per minute (or 400ms per word + 1.5s base)
    final words = questionText.split(' ').length;
    final durationMs = (words * 380) + 1200;
    Future.delayed(Duration(milliseconds: durationMs), () {
      if (mounted) {
        setState(() {
          _isEvaluatorSpeaking = false;
        });
      }
    });
  }

  void _startAnsweringOrally() {
    setState(() {
      _isUserListeningMic = true;
      _liveUserSpokenAnswer = '';
    });
    SpeechRecognitionService.stopSpeaking();

    SpeechRecognitionService.startListening(
      onResult: (text, isFinal) {
        if (mounted) {
          setState(() {
            _liveUserSpokenAnswer = text;
            _answerController.text = text;
          });
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() {
            _isUserListeningMic = false;
          });
        }
      },
    );
  }

  void _stopAnsweringOrally() {
    final finalTranscript = SpeechRecognitionService.stopListening();
    setState(() {
      _isUserListeningMic = false;
      if (finalTranscript.isNotEmpty) {
        _liveUserSpokenAnswer = finalTranscript;
        _answerController.text = finalTranscript;
      }
    });
  }

  void _submitCurrentAnswer() {
    if (_isUserListeningMic) {
      _stopAnsweringOrally();
    }

    final answerText = _answerController.text.trim().isNotEmpty
        ? _answerController.text.trim()
        : (_liveUserSpokenAnswer.trim().isNotEmpty
            ? _liveUserSpokenAnswer.trim()
            : 'I addressed this point with clear structure, steady pacing, and verified metrics.');

    // Save answer to questions array
    final currentQ = _questions[_currentQuestionIndex];
    _questions[_currentQuestionIndex] = AudienceQuestion(
      question: currentQ.question,
      speakerAnswer: answerText,
    );

    // If there is another question, proceed to next
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _liveUserSpokenAnswer = '';
        _answerController.clear();
      });
      _speakCurrentQuestion();
    } else {
      // All questions completed! Save session to history and show Report
      _finishQAAndShowReport();
    }
  }

  Future<void> _finishQAAndShowReport() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    // Update session questions in provider and database
    await provider.updateSessionQAAnswers(_session.id, _questions);

    if (!mounted) return;

    final updatedSession = PracticeSessionResult(
      id: _session.id,
      mode: _session.mode,
      evaluatorId: _session.evaluatorId,
      evaluatorName: _session.evaluatorName,
      categoryId: _session.categoryId,
      topic: _session.topic,
      timestamp: _session.timestamp,
      durationSeconds: _session.durationSeconds,
      overallScore: _session.overallScore,
      clarityScore: _session.clarityScore,
      confidenceScore: _session.confidenceScore,
      paceScore: _session.paceScore,
      fluencyScore: _session.fluencyScore,
      structureScore: _session.structureScore,
      fillerWordCount: _session.fillerWordCount,
      transcript: _session.transcript,
      strengths: _session.strengths,
      weaknesses: _session.weaknesses,
      howToImprove: _session.howToImprove,
      nextRecommendedExercise: _session.nextRecommendedExercise,
      recommendedBooks: _session.recommendedBooks,
      audienceQuestions: _questions,
      isSavedInInbox: true,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisReportScreen(result: updatedSession),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions.isNotEmpty
        ? _questions[_currentQuestionIndex].question
        : 'Could you elaborate on the core premise of your speech?';
    final totalQ = _questions.length;
    final currentNum = _currentQuestionIndex + 1;

    final isCoach = _session.evaluatorName.toLowerCase().contains('coach') ||
        _session.evaluatorName.toLowerCase().contains('story');

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () {
            // User can skip Q&A and jump straight to the report
            _finishQAAndShowReport();
          },
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎙️', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'EVALUATOR ORAL Q&A ($currentNum / $totalQ)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _finishQAAndShowReport,
            child: const Text(
              'Skip Q&A',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Evaluator Persona Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1E293B),
                      const Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isEvaluatorSpeaking ? AppColors.primaryCoral : Colors.white12,
                    width: _isEvaluatorSpeaking ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isEvaluatorSpeaking ? AppColors.primaryCoral : Colors.black).withValues(alpha: 0.35),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Evaluator Avatar with Animated Speaking Glow
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isEvaluatorSpeaking)
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 78 + (_pulseController.value * 12),
                                height: 78 + (_pulseController.value * 12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryCoral.withValues(alpha: 0.25),
                                ),
                              );
                            },
                          ),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBlue.withValues(alpha: 0.2),
                            border: Border.all(
                              color: _isEvaluatorSpeaking ? AppColors.primaryCoral : AppColors.primaryBlue,
                              width: 2.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isCoach ? '👔' : '💼',
                            style: const TextStyle(fontSize: 34),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Text(
                      _session.evaluatorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCoach
                            ? AppColors.motivationCoral.withValues(alpha: 0.2)
                            : AppColors.primaryBlue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isCoach ? 'Focused on Delivery & Emotion' : 'Focused on Content & Logic',
                        style: TextStyle(
                          color: isCoach ? AppColors.primaryCoral : AppColors.secondaryTeal,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Evaluator Question Text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isEvaluatorSpeaking ? Icons.volume_up_rounded : Icons.record_voice_over_rounded,
                                color: _isEvaluatorSpeaking ? AppColors.primaryCoral : Colors.white60,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isEvaluatorSpeaking ? 'Evaluator is speaking...' : 'Evaluator Question:',
                                style: TextStyle(
                                  color: _isEvaluatorSpeaking ? AppColors.primaryCoral : Colors.white60,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.replay_rounded, color: Colors.white70, size: 18),
                                tooltip: 'Listen Again',
                                onPressed: _speakCurrentQuestion,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '"$currentQuestion"',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. Trainee Spoken Answer Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isUserListeningMic ? AppColors.secondaryTeal : Colors.white12,
                    width: _isUserListeningMic ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isUserListeningMic ? AppColors.successGreen : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isUserListeningMic
                              ? 'Listening to your microphone...'
                              : 'Your Oral Spoken Answer:',
                          style: TextStyle(
                            color: _isUserListeningMic ? AppColors.secondaryTeal : Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Spoken Transcription Display Box
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 90),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        _answerController.text.isNotEmpty
                            ? _answerController.text
                            : (_isUserListeningMic
                                ? 'Speak now into your microphone...'
                                : 'Tap the microphone button below and answer the evaluator verbally.'),
                        style: TextStyle(
                          color: _answerController.text.isNotEmpty ? Colors.white : Colors.white38,
                          fontSize: 14,
                          height: 1.4,
                          fontStyle: _answerController.text.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Microphone Action Button
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_isUserListeningMic) {
                                _stopAnsweringOrally();
                              } else {
                                _startAnsweringOrally();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isUserListeningMic ? AppColors.successGreen : AppColors.primaryCoral,
                                boxShadow: [
                                  BoxShadow(
                                    color: (_isUserListeningMic ? AppColors.successGreen : AppColors.primaryCoral)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: _isUserListeningMic ? 6 : 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isUserListeningMic ? Icons.stop_rounded : Icons.mic_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isUserListeningMic ? 'Tap to Finish Speaking' : 'Tap to Answer Orally',
                            style: TextStyle(
                              color: _isUserListeningMic ? AppColors.secondaryTeal : Colors.white70,
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

              const SizedBox(height: 28),

              // 3. Confirm Answer & Next / Finish Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submitCurrentAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCoral,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentQuestionIndex < _questions.length - 1
                            ? 'Next Question ($currentNum/$totalQ) →'
                            : 'Complete Q&A & View Full Report ✓',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
