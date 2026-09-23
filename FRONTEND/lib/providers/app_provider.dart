import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/ai_evaluator.dart';
import '../models/book_recommendation.dart';
import '../models/category.dart';
import '../models/daily_knowledge_brief.dart';
import '../models/journey.dart';
import '../models/practice_session.dart';
import '../models/simulated_environment.dart';
import '../models/subscription_plan.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService.instance;
  bool _isBackendConnected = false;
  bool get isBackendConnected => _isBackendConnected;

  AppProvider() {
    _initBackendConnection();
  }

  // Database Avatar Presets
  final List<Map<String, dynamic>> _avatarPresets = [
    {
      'id': 'av_1',
      'label': 'Amina (Speaker)',
      'category': 'Professional',
      'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 'av_2',
      'label': 'Executive Leader',
      'category': 'Corporate',
      'url': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 'av_3',
      'label': 'Tech Innovator',
      'category': 'Technology',
      'url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 'av_4',
      'label': 'Keynote Presenter',
      'category': 'Keynote',
      'url': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 'av_5',
      'label': 'Visionary Coach',
      'category': 'Coaching',
      'url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 'av_6',
      'label': 'Speech Mentor',
      'category': 'Education',
      'url': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 'av_7',
      'label': 'Debate Champion',
      'category': 'Debate',
      'url': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=300&auto=format&fit=crop&q=80',
    },
    {
      'id': 'av_8',
      'label': 'Creative Storyteller',
      'category': 'Storytelling',
      'url': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&auto=format&fit=crop&q=80',
    },
  ];

  List<Map<String, dynamic>> get avatarPresets => _avatarPresets;

  Future<void> _initBackendConnection() async {
    _isBackendConnected = await _apiService.checkHealth();
    if (_isBackendConnected) {
      final briefs = await _apiService.fetchDailyBriefs();
      if (briefs != null && briefs.isNotEmpty) {
        _dailyBriefArchive.clear();
        _dailyBriefArchive.addAll(briefs);
      }
      final history = await _apiService.fetchSessionHistory();
      if (history != null && history.isNotEmpty) {
        _sessionHistory.clear();
        _sessionHistory.addAll(history);
      }
      final dbAvatars = await _apiService.getAvatarPresets();
      if (dbAvatars.isNotEmpty) {
        _avatarPresets.clear();
        _avatarPresets.addAll(dbAvatars);
      }
      notifyListeners();
    }
  }

  // Authentication & Role
  bool _isAuthenticated = false;
  String _userEmail = 'amina@speakup.ai';
  String _userName = 'Amina Bello';
  String? _userAvatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop&q=80';
  String _userRole = 'Trainee'; // 'Trainee' or 'Admin'
  bool _hasSeenSplash = false;


  // Global App Settings (Dark Mode & Audio Volume)
  bool _isDarkMode = false;
  double _audioVolume = 0.8; // 80% default feedback & ambient volume

  // Subscription Plan (Default Free Trainee: 0 FCFA)
  SubscriptionPlan _currentPlan = SubscriptionPlan.plans[0];

  // Streak & Points
  int _streakDays = 7;
  int _totalXP = 520;
  DateTime? _lastPracticeDate;

  // Career / Lifetime All-Time Scores & Registration Stats
  final DateTime _registrationDate = DateTime(2026, 9, 1);
  DateTime get registrationDate => _registrationDate;

  int get allTimeScoresTotal => _sessionHistory.fold(0, (sum, item) => sum + item.overallScore) + _totalXP;
  int get totalPracticesCount => _sessionHistory.length;
  double get lifetimeAverageScore =>
      _sessionHistory.isEmpty ? 82.5 : (_sessionHistory.fold(0, (sum, item) => sum + item.overallScore) / _sessionHistory.length);
  int get highestSessionScore =>
      _sessionHistory.isEmpty ? 88 : _sessionHistory.map((s) => s.overallScore).reduce(max);
  Set<int> get completedPracticeDaysInCurrentMonth => {18, 19, 20, 21, 22, 23, DateTime.now().day};

  void _tickDailyStreak() {
    final now = DateTime.now();
    if (_lastPracticeDate == null ||
        _lastPracticeDate!.day != now.day ||
        _lastPracticeDate!.month != now.month ||
        _lastPracticeDate!.year != now.year) {
      _streakDays += 1;
      _lastPracticeDate = now;
    }
  }

  // Feature Privileges & Access Control Gatekeeper
  bool get isProOrHigher => _currentPlan.tier == SubscriptionTier.pro || _currentPlan.tier == SubscriptionTier.plus;
  bool get isPlusOrEnterprise => _currentPlan.tier == SubscriptionTier.plus;

  bool isEvaluatorAllowed(AIEvaluator evaluator) {
    if (isPlusOrEnterprise) return true;
    if (evaluator.id == 'thesis_jury' || evaluator.id == 'debate_opponent') {
      return isPlusOrEnterprise;
    }
    if (evaluator.id == 'executive' || evaluator.id == 'advocate' || evaluator.id == 'stage' || evaluator.id == 'interview_evaluator') {
      return isProOrHigher;
    }
    return true; // 'coach', 'storyteller' are free
  }

  bool isEnvironmentAllowed(SimulatedEnvironment env) {
    if (isPlusOrEnterprise) return true;
    if (env.id == 'courtroom' || env.id == 'university_hall') {
      return isPlusOrEnterprise;
    }
    if (env.id == 'meeting_room' || env.id == 'tedx_stage') {
      return isProOrHigher;
    }
    return true; // 'bedroom' is free
  }

  bool get canAccessVideoMode => isProOrHigher;
  bool get canAccessDocumentContext => isProOrHigher;
  int get dailyFreePracticesLimit => 3;
  int get todayPracticesCount => _sessionHistory
      .where((s) =>
          s.timestamp.day == DateTime.now().day &&
          s.timestamp.month == DateTime.now().month &&
          s.timestamp.year == DateTime.now().year)
      .length;
  bool get hasReachedPracticeLimit => !isProOrHigher && todayPracticesCount >= dailyFreePracticesLimit;

  Future<void> changeSubscriptionPlan(SubscriptionPlan plan) async {
    _currentPlan = plan;
    if (_isBackendConnected) {
      final planId = plan.tier == SubscriptionTier.plus
          ? 'enterprise'
          : plan.tier == SubscriptionTier.pro
              ? 'pro'
              : 'free';
      await _apiService.subscribePlan(planId);
    }
    notifyListeners();
  }



  // Journey & Focus
  SpeakingObstacle _currentObstacle = JourneyData.obstacles.first;

  // Practice Setup & Environment
  AIEvaluator _selectedEvaluator = AIEvaluator.evaluators.first;

  CategoryItem _selectedCategory = CategoryItem.categories.first;
  SimulatedEnvironment _selectedEnvironment = SimulatedEnvironment.environments.first;
  String _currentTopic = 'Should artificial intelligence replace some entry-level jobs?';
  String? _speechDocumentContext;
  bool _isVideoMode = false;

  // Trainee Choice: Enable/Disable Simulated Environment
  bool _isSimulatedEnvironmentEnabled = true;
  String _simulationStrictness = 'Balanced';
  bool _enableAmbientAudio = true;
  bool _enableAudienceReactions = true;
  bool _enablePressureTimer = false;

  // Live Studio & Execution State
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  bool _isAnalyzing = false;
  PracticeSessionResult? _latestResult;

  // Session History & Feedback Inbox
  final List<PracticeSessionResult> _sessionHistory = List.from(PracticeSessionResult.mockHistory);

  // Daily Knowledge Brief Archive
  final List<DailyKnowledgeBrief> _dailyBriefArchive = List.from(DailyKnowledgeBrief.mockArchive);

  // Completed Node IDs
  final Set<String> _completedNodeIds = {'conf_1_1', 'conf_1_2', 'clar_1_1'};

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String get userEmail => _userEmail;
  String get userName => _userName;
  String? get userAvatarUrl => _userAvatarUrl;
  String get userRole => _userRole;
  bool get hasSeenSplash => _hasSeenSplash;
  bool get isDarkMode => _isDarkMode;
  double get audioVolume => _audioVolume;

  SubscriptionPlan get currentPlan => _currentPlan;
  int get streakDays => _streakDays;
  int get totalXP => _totalXP;

  // Dynamic User Level Classification based on Total Score / XP
  String get userLevel {
    if (_totalXP >= 3000) return 'Expert';
    if (_totalXP >= 1500) return 'Advanced';
    if (_totalXP >= 500) return 'Intermediate';
    return 'Beginner';
  }

  Color get userLevelColor {
    if (_totalXP >= 3000) return AppColors.primaryCoral;
    if (_totalXP >= 1500) return AppColors.primaryPurple;
    if (_totalXP >= 500) return AppColors.primaryBlue;
    return AppColors.secondaryTeal;
  }

  int get nextLevelTargetXP {
    if (_totalXP < 500) return 500;
    if (_totalXP < 1500) return 1500;
    if (_totalXP < 3000) return 3000;
    return 5000;
  }

  String get nextLevelName {
    if (_totalXP < 500) return 'Intermediate';
    if (_totalXP < 1500) return 'Advanced';
    if (_totalXP < 3000) return 'Expert';
    return 'Master';
  }

  double get levelProgressPercent {
    if (_totalXP < 500) return _totalXP / 500.0;
    if (_totalXP < 1500) return (_totalXP - 500) / 1000.0;
    if (_totalXP < 3000) return (_totalXP - 1500) / 1500.0;
    return min(1.0, (_totalXP - 3000) / 2000.0);
  }

  SpeakingObstacle get currentObstacle => _currentObstacle;
  AIEvaluator get selectedEvaluator => _selectedEvaluator;
  CategoryItem get selectedCategory => _selectedCategory;
  SimulatedEnvironment get selectedEnvironment => _selectedEnvironment;
  String get currentTopic => _currentTopic;
  String? get speechDocumentContext => _speechDocumentContext;
  bool get isVideoMode => _isVideoMode;

  bool get isSimulatedEnvironmentEnabled => _isSimulatedEnvironmentEnabled;
  String get simulationStrictness => _simulationStrictness;
  bool get enableAmbientAudio => _enableAmbientAudio;
  bool get enableAudienceReactions => _enableAudienceReactions;
  bool get enablePressureTimer => _enablePressureTimer;

  bool get isRecording => _isRecording;
  int get recordingSeconds => _recordingSeconds;
  bool get isAnalyzing => _isAnalyzing;
  PracticeSessionResult? get latestResult => _latestResult;

  List<PracticeSessionResult> get sessionHistory => List.unmodifiable(_sessionHistory);
  List<DailyKnowledgeBrief> get dailyBriefArchive => List.unmodifiable(_dailyBriefArchive);
  Set<String> get completedNodeIds => Set.unmodifiable(_completedNodeIds);

  // Settings Actions
  void toggleDarkMode([bool? val]) {
    _isDarkMode = val ?? !_isDarkMode;
    notifyListeners();
  }

  void setAudioVolume(double volume) {
    _audioVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  // Authentication Methods
  void setUserRoleDirectly(String role) {
    _userRole = role;
    notifyListeners();
  }

  Future<bool> login(String email, [String? password, String? role]) async {
    _userEmail = email;

    if (_isBackendConnected) {
      final res = await _apiService.login(email, password);
      if (res != null && res['user'] != null) {
        _userName = res['user']['name'] ?? _userName;
        _userEmail = res['user']['email'] ?? email;
        _userRole = role ?? res['user']['role'] ?? (email.toLowerCase().contains('admin') ? 'Admin' : 'Trainee');
        _streakDays = res['user']['streak_days'] ?? _streakDays;
        _totalXP = res['user']['total_xp'] ?? _totalXP;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    }

    // Local fallback if backend is starting
    _userName = email.toLowerCase().contains('admin') ? 'Platform Administrator' : email.split('@')[0];
    _userRole = role ?? (email.toLowerCase().contains('admin') ? 'Admin' : 'Trainee');
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<bool> register({required String name, required String email, String? password, String? role}) async {
    _userName = name.isNotEmpty ? name : 'Trainee';
    _userEmail = email;
    _userRole = role ?? 'Trainee';

    if (_isBackendConnected) {
      final res = await _apiService.register(name: name, email: email, password: password, role: _userRole);
      if (res != null && res['user'] != null) {
        _userName = res['user']['name'] ?? _userName;
        _userEmail = res['user']['email'] ?? email;
        _userRole = res['user']['role'] ?? _userRole;
        _streakDays = res['user']['streak_days'] ?? 1;
        _totalXP = res['user']['total_xp'] ?? 0; // New users classified as Beginner (0 XP)
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    }

    _totalXP = 0; // Beginner
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<bool> loginWithSocial({required String provider, String? email, String? name}) async {
    if (_isBackendConnected) {
      final res = await _apiService.socialLogin(provider: provider, email: email, name: name);
      if (res != null && res['user'] != null) {
        _userName = res['user']['name'] ?? (name ?? '${provider[0].toUpperCase()}${provider.substring(1)} User');
        _userEmail = res['user']['email'] ?? (email ?? '${provider}_user@speakup.ai');
        _userRole = res['user']['role'] ?? 'Trainee';
        _streakDays = res['user']['streak_days'] ?? 1;
        _totalXP = res['user']['total_xp'] ?? 0;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
    }

    // Fallback social authentication
    _userName = name ?? '${provider[0].toUpperCase()}${provider.substring(1)} User';
    _userEmail = email ?? '${provider.toLowerCase()}_user@speakup.ai';
    _userRole = 'Trainee';
    _totalXP = 0; // Beginner
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<Map<String, dynamic>?> forgotPassword(String email) async {
    if (_isBackendConnected) {
      return await _apiService.forgotPassword(email);
    }
    // Fallback simulated verification code
    final simulatedCode = '123456';
    return {
      'success': true,
      'message': 'Verification code sent to $email',
      'code': simulatedCode
    };
  }

  Future<bool> verifyResetCode(String email, String code) async {
    if (_isBackendConnected) {
      return await _apiService.verifyResetCode(email, code);
    }
    return code == '123456' || code.length == 6;
  }

  Future<bool> resetPassword(String email, String code, String newPassword) async {
    if (_isBackendConnected) {
      final res = await _apiService.resetPassword(email, code, newPassword);
      if (res != null && res['user'] != null) {
        _userName = res['user']['name'] ?? _userName;
        _userEmail = res['user']['email'] ?? email;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    }
    _userEmail = email;
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  Future<bool> updateProfile({required String name, required String email, String? obstacleId, String? avatarUrl}) async {
    _userName = name;
    _userEmail = email;
    if (avatarUrl != null) {
      _userAvatarUrl = avatarUrl.trim().isEmpty ? null : avatarUrl.trim();
    }
    if (_isBackendConnected) {
      await _apiService.updateProfile(name: name, email: email, obstacleId: obstacleId, avatarUrl: avatarUrl);
    }
    notifyListeners();
    return true;
  }

  void setUserAvatar(String? avatarUrl) {
    _userAvatarUrl = (avatarUrl != null && avatarUrl.trim().isNotEmpty) ? avatarUrl.trim() : null;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _apiService.setAuthToken(null);
    notifyListeners();
  }

  void setSplashSeen() {
    _hasSeenSplash = true;
    notifyListeners();
  }

  void toggleUserRole() {
    _userRole = (_userRole == 'Trainee') ? 'Admin' : 'Trainee';
    notifyListeners();
  }

  // Environment & Context Setup Actions
  void toggleSimulatedEnvironmentEnabled([bool? val]) {
    _isSimulatedEnvironmentEnabled = val ?? !_isSimulatedEnvironmentEnabled;
    notifyListeners();
  }

  void setSimulationStrictness(String strictness) {
    _simulationStrictness = strictness;
    notifyListeners();
  }

  void toggleAmbientAudio([bool? val]) {
    _enableAmbientAudio = val ?? !_enableAmbientAudio;
    notifyListeners();
  }

  void toggleAudienceReactions([bool? val]) {
    _enableAudienceReactions = val ?? !_enableAudienceReactions;
    notifyListeners();
  }

  void togglePressureTimer([bool? val]) {
    _enablePressureTimer = val ?? !_enablePressureTimer;
    notifyListeners();
  }

  void selectEnvironment(SimulatedEnvironment env) {
    _selectedEnvironment = env;
    notifyListeners();
  }

  void setSpeechDocumentContext(String? text) {
    _speechDocumentContext = text;
    notifyListeners();
  }

  void selectObstacle(SpeakingObstacle obstacle) {
    _currentObstacle = obstacle;
    notifyListeners();
  }

  void selectEvaluator(AIEvaluator evaluator) {
    _selectedEvaluator = evaluator;
    final matchedEnv = SimulatedEnvironment.environments.firstWhere(
      (env) => env.recommendedEvaluatorId == evaluator.id,
      orElse: () => _selectedEnvironment,
    );
    _selectedEnvironment = matchedEnv;
    notifyListeners();
  }

  void selectCategory(CategoryItem category) {
    _selectedCategory = category;
    _generateRandomTopicForCategory();
    notifyListeners();
  }

  void setTopic(String topic) {
    _currentTopic = topic;
    notifyListeners();
  }

  void toggleVideoMode() {
    _isVideoMode = !_isVideoMode;
    notifyListeners();
  }

  void _generateRandomTopicForCategory() {
    final list = _selectedCategory.sampleTopics;
    if (list.isNotEmpty) {
      _currentTopic = list[Random().nextInt(list.length)];
    }
  }

  void spinRandomTopic() {
    _generateRandomTopicForCategory();
    notifyListeners();
  }

  // Live Recording & AI Evaluation Engine
  void startRecording() {
    _isRecording = true;
    _recordingSeconds = 0;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingSeconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> stopRecordingAndAnalyze({PracticeMode mode = PracticeMode.full, String? nodeTitle}) async {
    _recordingTimer?.cancel();
    _isRecording = false;
    _isAnalyzing = true;
    notifyListeners();

    if (_isBackendConnected) {
      final apiResult = await _apiService.submitAndAnalyzeSession(
        mode: mode,
        evaluatorId: _selectedEvaluator.id,
        evaluatorName: _selectedEvaluator.name,
        categoryId: _selectedCategory.id,
        topic: nodeTitle ?? _currentTopic,
        durationSeconds: _recordingSeconds > 0 ? _recordingSeconds : 45,
      );

      if (apiResult != null) {
        _latestResult = apiResult;
        _sessionHistory.insert(0, apiResult);
        _totalXP += 50; // Increases XP and automatically promotes level
        _tickDailyStreak(); // Automatically tick streak
        _isAnalyzing = false;
        notifyListeners();
        return;
      }
    }

    // Fallback simulated evaluation if backend is starting
    await Future.delayed(const Duration(seconds: 2));
    final rand = Random();
    final overall = 78 + rand.nextInt(18);
    final clarity = 80 + rand.nextInt(16);
    final confidence = 75 + rand.nextInt(20);
    final pace = 78 + rand.nextInt(18);
    final fluency = 74 + rand.nextInt(20);
    final structure = 80 + rand.nextInt(16);
    final fillers = rand.nextInt(4);

    final weaknesses = [
      fillers > 1 ? 'Used $fillers minor filler words during transitions' : 'Slight pauses before opening hooks',
      'Vocal inflection can be elevated at concluding statement'
    ];

    final recommendedBooks = BookRecommendation.getRecommendationsForWeakness(
      clarityScore: clarity,
      confidenceScore: confidence,
      paceScore: pace,
      fluencyScore: fluency,
      structureScore: structure,
      fillerWordCount: fillers,
      weaknesses: weaknesses,
    );

    final result = PracticeSessionResult(
      id: 'sess_${DateTime.now().millisecondsSinceEpoch}',
      mode: mode,
      evaluatorId: _selectedEvaluator.id,
      evaluatorName: _selectedEvaluator.name,
      categoryId: _selectedCategory.id,
      topic: nodeTitle ?? _currentTopic,
      timestamp: DateTime.now(),
      durationSeconds: _recordingSeconds > 0 ? _recordingSeconds : 45,
      overallScore: overall,
      clarityScore: clarity,
      confidenceScore: confidence,
      paceScore: pace,
      fluencyScore: fluency,
      structureScore: structure,
      fillerWordCount: fillers,
      transcript:
          'Thank you for this opportunity. In my presentation on ${_selectedCategory.title}, I want to outline how structured arguments and vocal clarity allow us to project confidence in any ${_selectedEnvironment.title} setting.',
      strengths: [
        'Strong projection and vocal confidence',
        'Well-structured points matching your uploaded report context',
        'Excellent eye contact and steady tempo'
      ],
      weaknesses: weaknesses,
      howToImprove:
          'Take a deep 2-second pause before introducing key evidence. Review recommended reading on vocal pacing.',
      nextRecommendedExercise: 'Practice defending counter-objections in the ${_selectedEnvironment.title}.',
      recommendedBooks: recommendedBooks,
      audienceQuestions: [
        AudienceQuestion(
          question: '${_selectedEvaluator.name} Question: How would you address an executive stakeholder who challenges your uploaded report data?',
          speakerAnswer:
              'I would acknowledge their question, reference section 2 of my attached document context, and outline the risk mitigation strategy.',
        ),
      ],
    );

    _latestResult = result;
    _sessionHistory.insert(0, result);
    _totalXP += 50; // XP progression
    _tickDailyStreak(); // Automatically tick streak
    _isAnalyzing = false;
    notifyListeners();
  }

  Future<void> completeNode(String nodeId) async {
    _completedNodeIds.add(nodeId);
    _totalXP += 75; // XP progression
    _tickDailyStreak(); // Automatically tick streak

    if (_isBackendConnected) {
      final res = await _apiService.completeNode(nodeId);
      if (res != null && res['totalXP'] != null) {
        _totalXP = res['totalXP'];
      }
    }
    notifyListeners();
  }


  Future<void> markBriefAsRead(String briefId) async {
    final idx = _dailyBriefArchive.indexWhere((b) => b.id == briefId);
    if (idx != -1) {
      final old = _dailyBriefArchive[idx];
      _dailyBriefArchive[idx] = DailyKnowledgeBrief(
        id: old.id,
        date: old.date,
        category: old.category,
        topic: old.topic,
        emoji: old.emoji,
        summaryText: old.summaryText,
        keyFactBullets: old.keyFactBullets,
        suggestedSpeakingPrompt: old.suggestedSpeakingPrompt,
        isRead: true,
      );
      _totalXP += 25; // Reading daily brief gives XP
      notifyListeners();
    }

    if (_isBackendConnected) {
      await _apiService.markBriefAsRead(briefId);
    }
  }
}
