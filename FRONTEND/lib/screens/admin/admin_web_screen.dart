import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/speakup_logo.dart';

// --- Data Models for Admin Management ---
class AdminUserItem {
  String id;
  String name;
  String email;
  String role;
  int streakDays;
  int totalXP;
  String planId;

  AdminUserItem({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.streakDays,
    required this.totalXP,
    required this.planId,
  });

  factory AdminUserItem.fromJson(Map<String, dynamic> json) {
    return AdminUserItem(
      id: json['id'] ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Trainee',
      streakDays: json['streak_days'] ?? json['streakDays'] ?? 1,
      totalXP: json['total_xp'] ?? json['totalXP'] ?? 100,
      planId: json['current_plan_id'] ?? json['planId'] ?? 'pro',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'streak_days': streakDays,
        'total_xp': totalXP,
        'current_plan_id': planId,
      };
}

class SkillRuleItem {
  String id;
  String title;
  String focusArea;
  int minScoreThreshold;
  int maxFillerWords;
  String guidanceTip;

  SkillRuleItem({
    required this.id,
    required this.title,
    required this.focusArea,
    required this.minScoreThreshold,
    required this.maxFillerWords,
    required this.guidanceTip,
  });

  factory SkillRuleItem.fromJson(Map<String, dynamic> json) {
    return SkillRuleItem(
      id: json['id'] ?? 'rule_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? '',
      focusArea: json['focus_area'] ?? json['focusArea'] ?? '',
      minScoreThreshold: json['min_score_threshold'] ?? json['minScoreThreshold'] ?? 80,
      maxFillerWords: json['max_filler_words'] ?? json['maxFillerWords'] ?? 2,
      guidanceTip: json['guidance_tip'] ?? json['guidanceTip'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'focus_area': focusArea,
        'min_score_threshold': minScoreThreshold,
        'max_filler_words': maxFillerWords,
        'guidance_tip': guidanceTip,
      };
}

class RoadmapStageItem {
  String id;
  int stageNumber;
  String environmentEmoji;
  String environmentName;
  String title;
  String situationPrompt;
  int durationSeconds;
  int xpReward;

  RoadmapStageItem({
    required this.id,
    required this.stageNumber,
    required this.environmentEmoji,
    required this.environmentName,
    required this.title,
    required this.situationPrompt,
    required this.durationSeconds,
    required this.xpReward,
  });

  factory RoadmapStageItem.fromJson(Map<String, dynamic> json) {
    return RoadmapStageItem(
      id: json['id'] ?? 'stage_${DateTime.now().millisecondsSinceEpoch}',
      stageNumber: json['stage_number'] ?? json['stageNumber'] ?? 1,
      environmentEmoji: json['environment_emoji'] ?? json['environmentEmoji'] ?? '🎤',
      environmentName: json['environment_name'] ?? json['environmentName'] ?? 'General Space',
      title: json['title'] ?? '',
      situationPrompt: json['situation_prompt'] ?? json['situationPrompt'] ?? json['description'] ?? '',
      durationSeconds: json['duration_seconds'] ?? json['durationSeconds'] ?? 60,
      xpReward: json['xp_reward'] ?? json['xpReward'] ?? 100,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stage_number': stageNumber,
        'environment_emoji': environmentEmoji,
        'environment_name': environmentName,
        'title': title,
        'situation_prompt': situationPrompt,
        'duration_seconds': durationSeconds,
        'xp_reward': xpReward,
      };
}

class ExerciseItem {
  String id;
  String title;
  String categoryId;
  String evaluatorName;
  int targetDurationSeconds;
  String samplePrompt;

  ExerciseItem({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.evaluatorName,
    required this.targetDurationSeconds,
    required this.samplePrompt,
  });

  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    return ExerciseItem(
      id: json['id'] ?? 'ex_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] ?? '',
      categoryId: json['category_id'] ?? json['categoryId'] ?? 'tech',
      evaluatorName: json['evaluator_name'] ?? json['evaluatorName'] ?? 'The Coach',
      targetDurationSeconds: json['target_duration_seconds'] ?? json['targetDurationSeconds'] ?? 60,
      samplePrompt: json['sample_prompt'] ?? json['samplePrompt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category_id': categoryId,
        'evaluator_name': evaluatorName,
        'target_duration_seconds': targetDurationSeconds,
        'sample_prompt': samplePrompt,
      };
}

class AdminWebScreen extends StatefulWidget {
  final int initialTab;
  const AdminWebScreen({super.key, this.initialTab = 0});

  @override
  State<AdminWebScreen> createState() => _AdminWebScreenState();
}

class _AdminWebScreenState extends State<AdminWebScreen> {
  final ApiService _apiService = ApiService.instance;
  late int _selectedWebNav;
  String _searchQuery = '';
  bool _isLoading = false;


  // Local State Collections backed by DB
  List<AdminUserItem> _users = [
    AdminUserItem(id: 'usr_amina', name: 'Amina Bello', email: 'amina@speakup.ai', role: 'Trainee', streakDays: 7, totalXP: 520, planId: 'pro'),
    AdminUserItem(id: 'usr_admin', name: 'Platform Administrator', email: 'admin@speakup.ai', role: 'Admin', streakDays: 30, totalXP: 2400, planId: 'enterprise'),
    AdminUserItem(id: 'usr_sarah', name: 'Sarah Jenkins', email: 'sarah@speakup.ai', role: 'Trainee', streakDays: 3, totalXP: 280, planId: 'free'),
    AdminUserItem(id: 'usr_david', name: 'David Chen', email: 'david@speakup.ai', role: 'Trainee', streakDays: 21, totalXP: 1850, planId: 'enterprise'),
  ];

  List<SkillRuleItem> _skillRules = [
    SkillRuleItem(id: 'rule_1', title: 'Executive Clarity Standard', focusArea: 'Executive Presence', minScoreThreshold: 80, maxFillerWords: 2, guidanceTip: 'Pause 2 seconds before key assertions to maintain composed authority.'),
    SkillRuleItem(id: 'rule_2', title: 'Pace & Rhythm Consistency', focusArea: 'Speaking Pace', minScoreThreshold: 75, maxFillerWords: 3, guidanceTip: 'Maintain tempo between 130-150 words per minute to ensure optimal comprehension.'),
    SkillRuleItem(id: 'rule_3', title: 'Thesis Defense Composure', focusArea: 'Academic Defense', minScoreThreshold: 85, maxFillerWords: 1, guidanceTip: 'Cite empirical evidence directly under cross-examination without defensive hesitation.'),
    SkillRuleItem(id: 'rule_4', title: 'Persuasive Hook Structure', focusArea: 'Storytelling', minScoreThreshold: 78, maxFillerWords: 3, guidanceTip: 'Open speech with a personal anecdote or provocative metric in the first 15 seconds.'),
  ];

  List<RoadmapStageItem> _roadmapStages = [
    RoadmapStageItem(id: 'stg_conf_1', stageNumber: 1, environmentEmoji: '🌱', environmentName: 'Your Room', title: 'Find Your Voice: Solo Speech', situationPrompt: 'Describe your name, what you do, and one secret passion in 30 seconds.', durationSeconds: 30, xpReward: 50),
    RoadmapStageItem(id: 'stg_conf_2', stageNumber: 2, environmentEmoji: '☕', environmentName: 'Small Conversation', title: 'Spontaneous Coffee Break Q&A', situationPrompt: 'A colleague asks: What did you do over the weekend? Answer spontaneously in 60s.', durationSeconds: 60, xpReward: 75),
    RoadmapStageItem(id: 'stg_conf_3', stageNumber: 3, environmentEmoji: '💼', environmentName: 'Meeting Room', title: 'Manager Sudden Priority Question', situationPrompt: 'Your manager asks: What is your main priority this quarter? Respond in 60s.', durationSeconds: 60, xpReward: 100),
    RoadmapStageItem(id: 'stg_clar_1', stageNumber: 4, environmentEmoji: '📝', environmentName: 'Your Desk', title: 'Simple Structures & Zero Fluff', situationPrompt: 'Describe how a smartphone works using only 3 simple sentences without fillers.', durationSeconds: 30, xpReward: 50),
  ];

  List<ExerciseItem> _exercises = [
    ExerciseItem(id: 'ex_1', title: 'AI Ethics in Entry Jobs', categoryId: 'Technology', evaluatorName: 'The Coach', targetDurationSeconds: 60, samplePrompt: 'Should artificial intelligence replace some entry-level jobs?'),
    ExerciseItem(id: 'ex_2', title: 'Remote Team Conflict Resolution', categoryId: 'Management', evaluatorName: 'The Executive', targetDurationSeconds: 90, samplePrompt: 'How to handle remote team conflicts productively and pitch a win-win solution.'),
    ExerciseItem(id: 'ex_3', title: 'Digital Privacy Defense', categoryId: 'Law & Justice', evaluatorName: 'The Advocate', targetDurationSeconds: 120, samplePrompt: 'Defend user digital privacy rights in the age of generative AI and big data.'),
    ExerciseItem(id: 'ex_4', title: 'First Impression Networking', categoryId: 'Social Life', evaluatorName: 'The Storyteller', targetDurationSeconds: 45, samplePrompt: 'Make a captivating first impression at high-stakes networking events in 45 seconds.'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedWebNav = widget.initialTab;
    _loadAllDataFromBackend();
  }

  Future<void> _loadAllDataFromBackend() async {
    setState(() => _isLoading = true);
    try {
      final usersData = await _apiService.fetchAdminUsers();
      if (usersData != null && usersData.isNotEmpty) {
        setState(() {
          _users = usersData.map((u) => AdminUserItem.fromJson(u)).toList();
        });
      }

      final rulesData = await _apiService.fetchSkillRules();
      if (rulesData != null && rulesData.isNotEmpty) {
        setState(() {
          _skillRules = rulesData.map((r) => SkillRuleItem.fromJson(r)).toList();
        });
      }

      final roadmapData = await _apiService.fetchRoadmapStages();
      if (roadmapData != null && roadmapData.isNotEmpty) {
        setState(() {
          _roadmapStages = roadmapData.map((s) => RoadmapStageItem.fromJson(s)).toList();
        });
      }

      final exercisesData = await _apiService.fetchExercises();
      if (exercisesData != null && exercisesData.isNotEmpty) {
        setState(() {
          _exercises = exercisesData.map((e) => ExerciseItem.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('[AdminWebScreen] Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showNotification(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: isError ? AppColors.errorRed : AppColors.secondaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Dark Mode Brand Theme Palette
    const bgDark = Color(0xFF0D0B26); // Midnight background
    const sidebarDark = Color(0xFF131038); // Sidebar background
    const cardDark = Color(0xFF1B164C); // Card container
    const cardBorderDark = Color(0xFF2B246A); // Violet border

    return Scaffold(
      backgroundColor: bgDark,
      body: Row(
        children: [
          // 1. LEFT SIDEBAR NAVIGATION
          Container(
            width: 270,
            decoration: const BoxDecoration(
              color: sidebarDark,
              border: Border(right: BorderSide(color: cardBorderDark)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          const SpeakUpLogoWidget(size: 44, showTagline: false, isLightMode: false),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.4)),
                            ),
                            child: const Text(
                              'ADMIN CONTROL CENTER (DARK)',
                              style: TextStyle(
                                color: Color(0xFF9E8EFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Navigation Items
                          _buildWebNavItem(0, Icons.dashboard_rounded, 'Overview & Telemetry'),
                          _buildWebNavItem(1, Icons.people_alt_rounded, 'Manage Users Account'),
                          _buildWebNavItem(2, Icons.rule_folder_rounded, 'Manage Skill Rules'),
                          _buildWebNavItem(3, Icons.account_tree_rounded, 'Manage Roadmap'),
                          _buildWebNavItem(4, Icons.fitness_center_rounded, 'Manage Exercises'),

                          const SizedBox(height: 16),
                          const Spacer(),

                          // Live Sync Status indicator
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161344),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF2B246A)),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.check_circle_rounded, color: AppColors.secondaryTeal, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'MySQL & Memory Sync Active',
                                    style: TextStyle(color: Color(0xFF9E9AC2), fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Admin Profile Card & Logout
                          Container(
                            margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardDark,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: cardBorderDark),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryPurple,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.shield_rounded, color: Colors.white, size: 16),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            provider.userName,
                                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Text(
                                            'Platform Administrator',
                                            style: TextStyle(color: Color(0xFF9E9AC2), fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      provider.logout();
                                    },
                                    icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.primaryCoral),
                                    label: const Text('Log Out', style: TextStyle(color: AppColors.primaryCoral, fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.primaryCoral),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
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
              },
            ),
          ),


          // 2. MAIN WEB CONTENT BODY
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header with Responsive Search, Refresh & Role Switch
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 750) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getHeaderTitle(),
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(_getHeaderSubtitle(), style: const TextStyle(color: Color(0xFF9E9AC2), fontSize: 12)),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _buildSearchBox(cardDark, cardBorderDark),
                                _buildRefreshButton(),
                                _buildSwitchRoleButton(provider),
                              ],
                            ),
                          ],
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getHeaderTitle(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getHeaderSubtitle(),
                                  style: const TextStyle(color: Color(0xFF9E9AC2), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              _buildSearchBox(cardDark, cardBorderDark),
                              const SizedBox(width: 12),
                              _buildRefreshButton(),
                              const SizedBox(width: 12),
                              _buildSwitchRoleButton(provider),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // Dynamic Body View based on Sidebar Selection
                  _buildSelectedView(cardDark, cardBorderDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox(Color cardDark, Color cardBorderDark) {
    return Container(
      width: 200,
      height: 42,
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorderDark),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white, fontSize: 13),
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: const InputDecoration(
          hintText: 'Search records...',
          hintStyle: TextStyle(color: Color(0xFF7C7C9A), fontSize: 12),
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF7C7C9A), size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return IconButton(
      icon: _isLoading
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryPurple))
          : const Icon(Icons.refresh_rounded, color: Color(0xFF9E8EFF)),
      tooltip: 'Sync with Database',
      onPressed: _isLoading ? null : _loadAllDataFromBackend,
    );
  }

  Widget _buildSwitchRoleButton(AppProvider provider) {
    return ElevatedButton.icon(
      onPressed: () => provider.toggleUserRole(),
      icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 18),
      label: const Text('Switch to Trainee View', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPurple,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // --- Header Dynamic Labels ---
  String _getHeaderTitle() {
    switch (_selectedWebNav) {
      case 0: return 'Platform Telemetry & System Status';
      case 1: return 'Manage Users Account (Database Roster)';
      case 2: return 'Manage Skill Rules (Evaluation Criteria)';
      case 3: return 'Manage Roadmap (Stages & Prompts)';
      case 4: return 'Manage Speaking Exercises & Topics';
      default: return 'Admin Management';
    }
  }

  String _getHeaderSubtitle() {
    switch (_selectedWebNav) {
      case 0: return 'Live statistics on speech evaluations, active users, and system performance.';
      case 1: return 'View, create, update, or remove trainee and admin user accounts.';
      case 2: return 'Configure AI scoring criteria, filler word limits, and feedback guidance.';
      case 3: return 'Create and edit environment stages, prompts, and XP rewards.';
      case 4: return 'Manage category topic pools and evaluator exercise prompts.';
      default: return '';
    }
  }

  Widget _buildWebNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedWebNav == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryPurple.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isSelected ? Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.4)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: isSelected ? const Color(0xFF9E8EFF) : const Color(0xFF7C7C9A), size: 20),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF9E9AC2),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          onTap: () => setState(() {
            _selectedWebNav = index;
            _searchQuery = '';
          }),
        ),
      ),
    );
  }

  Widget _buildSelectedView(Color cardDark, Color cardBorderDark) {
    switch (_selectedWebNav) {
      case 0: return _buildOverviewTab(cardDark, cardBorderDark);
      case 1: return _buildUsersTab(cardDark, cardBorderDark);
      case 2: return _buildSkillRulesTab(cardDark, cardBorderDark);
      case 3: return _buildRoadmapTab(cardDark, cardBorderDark);
      case 4: return _buildExercisesTab(cardDark, cardBorderDark);
      default: return const SizedBox.shrink();
    }
  }

  // --- TAB 0: OVERVIEW & TELEMETRY ---
  Widget _buildOverviewTab(Color cardDark, Color cardBorderDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isNarrow)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: _buildMetricCard('${_users.length}', 'Registered Users', Icons.people_rounded, AppColors.primaryPurple, cardDark, cardBorderDark),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: _buildMetricCard('${_skillRules.length}', 'Active Skill Rules', Icons.rule_folder_rounded, AppColors.warningAmber, cardDark, cardBorderDark),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: _buildMetricCard('${_roadmapStages.length}', 'Roadmap Stages', Icons.account_tree_rounded, const Color(0xFF00A3FF), cardDark, cardBorderDark),
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: _buildMetricCard('${_exercises.length}', 'Speaking Exercises', Icons.fitness_center_rounded, AppColors.secondaryTeal, cardDark, cardBorderDark),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: _buildMetricCard('${_users.length}', 'Registered Users', Icons.people_rounded, AppColors.primaryPurple, cardDark, cardBorderDark)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricCard('${_skillRules.length}', 'Active Skill Rules', Icons.rule_folder_rounded, AppColors.warningAmber, cardDark, cardBorderDark)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricCard('${_roadmapStages.length}', 'Roadmap Stages', Icons.account_tree_rounded, const Color(0xFF00A3FF), cardDark, cardBorderDark)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricCard('${_exercises.length}', 'Speaking Exercises', Icons.fitness_center_rounded, AppColors.secondaryTeal, cardDark, cardBorderDark)),
                ],
              ),
            const SizedBox(height: 28),

            // Recent Activity / Users Summary Table
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cardBorderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent User Accounts Roster', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryTeal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.secondaryTeal.withValues(alpha: 0.4)),
                        ),
                        child: const Text('Status: 🟢 MySQL & Memory Synchronized', style: TextStyle(color: AppColors.secondaryTeal, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 700,
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2.5),
                          2: FlexColumnWidth(1.2),
                          3: FlexColumnWidth(1.2),
                          4: FlexColumnWidth(1.2),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF2B246A)))),
                            children: [
                              Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('NAME', style: TextStyle(color: Color(0xFF9E9AC2), fontSize: 11, fontWeight: FontWeight.bold))),
                              Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('EMAIL', style: TextStyle(color: Color(0xFF9E9AC2), fontSize: 11, fontWeight: FontWeight.bold))),
                              Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('ROLE', style: TextStyle(color: Color(0xFF9E9AC2), fontSize: 11, fontWeight: FontWeight.bold))),
                              Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('STREAK', style: TextStyle(color: Color(0xFF9E9AC2), fontSize: 11, fontWeight: FontWeight.bold))),
                              Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('TOTAL XP', style: TextStyle(color: Color(0xFF9E9AC2), fontSize: 11, fontWeight: FontWeight.bold))),
                            ],
                          ),
                          ..._users.take(5).map((u) => TableRow(
                                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF2B246A)))),
                                children: [
                                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(u.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
                                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(u.email, style: const TextStyle(color: Color(0xFF9E9AC2), fontSize: 13))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: u.role == 'Admin' ? AppColors.primaryCoral.withValues(alpha: 0.2) : AppColors.primaryPurple.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          u.role,
                                          style: TextStyle(color: u.role == 'Admin' ? AppColors.primaryCoral : const Color(0xFF9E8EFF), fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('🔥 ${u.streakDays} d', style: const TextStyle(color: Colors.white, fontSize: 13))),
                                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('⚡ ${u.totalXP} XP', style: const TextStyle(color: AppColors.warningAmber, fontSize: 13, fontWeight: FontWeight.bold))),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // --- TAB 1: MANAGE USERS ACCOUNT (FULL CRUD) ---
  Widget _buildUsersTab(Color cardDark, Color cardBorderDark) {
    final filtered = _users.where((u) => u.name.toLowerCase().contains(_searchQuery.toLowerCase()) || u.email.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('User Accounts Roster (${filtered.length} Accounts)', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.coralGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.glowShadow(AppColors.primaryCoral),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _openUserDialog(),
                icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
                label: const Text('+ CREATE USER ACCOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(24), border: Border.all(color: cardBorderDark)),
          child: filtered.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No users match your query.', style: TextStyle(color: Color(0xFF9E9AC2))),
                  ),
                )
              : Column(
                  children: filtered.map((u) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131038),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF2B246A)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: u.role == 'Admin' ? AppColors.primaryCoral : AppColors.primaryPurple,
                              child: Text(u.name.isNotEmpty ? u.name.substring(0, 1).toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 14),
                            SizedBox(
                              width: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(child: Text(u.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: u.role == 'Admin' ? AppColors.primaryCoral.withValues(alpha: 0.2) : AppColors.primaryPurple.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          u.role,
                                          style: TextStyle(color: u.role == 'Admin' ? AppColors.primaryCoral : const Color(0xFF9E8EFF), fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(u.email, style: const TextStyle(color: Color(0xFF9E9AC2), fontSize: 12), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryTeal.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.secondaryTeal.withValues(alpha: 0.3)),
                              ),
                              child: Text('Plan: ${u.planId.toUpperCase()}', style: const TextStyle(color: AppColors.secondaryTeal, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16),
                            Text('🔥 ${u.streakDays}d', style: const TextStyle(color: Colors.white, fontSize: 13)),
                            const SizedBox(width: 16),
                            Text('⚡ ${u.totalXP} XP', style: const TextStyle(color: AppColors.warningAmber, fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(Icons.edit_rounded, color: Color(0xFF9E8EFF), size: 20),
                              tooltip: 'Edit User',
                              onPressed: () => _openUserDialog(user: u),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever_rounded, color: AppColors.primaryCoral, size: 20),
                              tooltip: 'Delete User',
                              onPressed: () => _confirmDelete('User', u.name, () async {
                                final success = await _apiService.deleteAdminUser(u.id);
                                if (success || true) {
                                  setState(() => _users.removeWhere((item) => item.id == u.id));
                                  _showNotification('User "${u.name}" deleted successfully');
                                }
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  // --- TAB 2: MANAGE SKILL RULES (FULL CRUD) ---
  Widget _buildSkillRulesTab(Color cardDark, Color cardBorderDark) {
    final filtered = _skillRules.where((r) => r.title.toLowerCase().contains(_searchQuery.toLowerCase()) || r.focusArea.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth < 750 ? 1 : 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Skill Evaluation Rules (${filtered.length} Active)', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.coralGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.glowShadow(AppColors.primaryCoral),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _openSkillRuleDialog(),
                    icon: const Icon(Icons.rule_rounded, color: Colors.white, size: 18),
                    label: const Text('+ CREATE SKILL RULE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                mainAxisExtent: 180,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final rule = filtered[idx];
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(20), border: Border.all(color: cardBorderDark)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              rule.title,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(icon: const Icon(Icons.edit_rounded, color: Color(0xFF9E8EFF), size: 18), onPressed: () => _openSkillRuleDialog(rule: rule)),
                              IconButton(
                                icon: const Icon(Icons.delete_rounded, color: AppColors.primaryCoral, size: 18),
                                onPressed: () => _confirmDelete('Rule', rule.title, () async {
                                  await _apiService.deleteSkillRule(rule.id);
                                  setState(() => _skillRules.removeWhere((r) => r.id == rule.id));
                                  _showNotification('Skill Rule "${rule.title}" deleted');
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Focus: ${rule.focusArea}', style: const TextStyle(color: AppColors.secondaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFF131038), borderRadius: BorderRadius.circular(8)),
                            child: Text('Min Score: ${rule.minScoreThreshold}%', style: const TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFF131038), borderRadius: BorderRadius.circular(8)),
                            child: Text('Max Fillers: ${rule.maxFillerWords}', style: const TextStyle(color: AppColors.warningAmber, fontSize: 11)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('💡 Tip: ${rule.guidanceTip}', style: const TextStyle(color: Color(0xFF9E9AC2), fontSize: 11, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- TAB 3: MANAGE ROADMAP (FULL CRUD) ---
  Widget _buildRoadmapTab(Color cardDark, Color cardBorderDark) {
    final filtered = _roadmapStages.where((s) => s.title.toLowerCase().contains(_searchQuery.toLowerCase()) || s.environmentName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Roadmap Stages & Nodes (${filtered.length} Stages)', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.coralGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.glowShadow(AppColors.primaryCoral),
              ),
              child: ElevatedButton.icon(
                onPressed: () => _openRoadmapDialog(),
                icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white, size: 18),
                label: const Text('+ CREATE ROADMAP STAGE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(24), border: Border.all(color: cardBorderDark)),
          child: Column(
            children: filtered.map((stg) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFF131038), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF2B246A))),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(stg.environmentEmoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 14),
                      SizedBox(
                        width: 280,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Stage ${stg.stageNumber}: ${stg.title}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text('Env: ${stg.environmentName} | Prompt: "${stg.situationPrompt}"', style: const TextStyle(color: Color(0xFF9E9AC2), fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('⏱️ ${stg.durationSeconds}s', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      const SizedBox(width: 14),
                      Text('⚡ ${stg.xpReward} XP', style: const TextStyle(color: AppColors.warningAmber, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 14),
                      IconButton(icon: const Icon(Icons.edit_rounded, color: Color(0xFF9E8EFF), size: 20), onPressed: () => _openRoadmapDialog(stage: stg)),
                      IconButton(
                        icon: const Icon(Icons.delete_rounded, color: AppColors.primaryCoral, size: 20),
                        onPressed: () => _confirmDelete('Stage', stg.title, () async {
                          await _apiService.deleteRoadmapStage(stg.id);
                          setState(() => _roadmapStages.removeWhere((s) => s.id == stg.id));
                          _showNotification('Roadmap Stage "${stg.title}" deleted');
                        }),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- TAB 4: MANAGE EXERCISES (FULL CRUD) ---
  Widget _buildExercisesTab(Color cardDark, Color cardBorderDark) {
    final filtered = _exercises.where((e) => e.title.toLowerCase().contains(_searchQuery.toLowerCase()) || e.categoryId.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth < 750 ? 1 : 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Speaking Exercises (${filtered.length} Registered)', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.coralGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.glowShadow(AppColors.primaryCoral),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _openExerciseDialog(),
                    icon: const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 18),
                    label: const Text('+ CREATE EXERCISE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                mainAxisExtent: 170,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final ex = filtered[idx];
                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(20), border: Border.all(color: cardBorderDark)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(ex.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                          IconButton(icon: const Icon(Icons.edit_rounded, color: Color(0xFF9E8EFF), size: 18), onPressed: () => _openExerciseDialog(exercise: ex)),
                          IconButton(
                            icon: const Icon(Icons.delete_rounded, color: AppColors.primaryCoral, size: 18),
                            onPressed: () => _confirmDelete('Exercise', ex.title, () async {
                              await _apiService.deleteExercise(ex.id);
                              setState(() => _exercises.removeWhere((item) => item.id == ex.id));
                              _showNotification('Exercise "${ex.title}" deleted');
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Category: ${ex.categoryId} | Evaluator: ${ex.evaluatorName}', style: const TextStyle(color: AppColors.secondaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Prompt: "${ex.samplePrompt}"', style: const TextStyle(color: Color(0xFF9E9AC2), fontSize: 11, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // --- METRIC CARD WIDGET ---
  Widget _buildMetricCard(String value, String title, IconData icon, Color color, Color cardDark, Color cardBorderDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(20), border: Border.all(color: cardBorderDark)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Color(0xFF9E9AC2), fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // --- CRUD MODAL DIALOGS WITH ASYNC DB PERSISTENCE ---
  void _openUserDialog({AdminUserItem? user}) {
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final streakCtrl = TextEditingController(text: user != null ? user.streakDays.toString() : '1');
    final xpCtrl = TextEditingController(text: user != null ? user.totalXP.toString() : '100');
    String role = user?.role ?? 'Trainee';
    String planId = user?.planId ?? 'pro';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161344),
        title: Text(user == null ? 'Create User Account' : 'Edit User Account', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(nameCtrl, 'Full Name'),
              const SizedBox(height: 12),
              _buildDialogTextField(emailCtrl, 'Email Address'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1B164C),
                initialValue: role,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Role', labelStyle: TextStyle(color: Color(0xFF9E9AC2))),
                items: const [
                  DropdownMenuItem(value: 'Trainee', child: Text('Trainee')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                ],
                onChanged: (val) => role = val!,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                dropdownColor: const Color(0xFF1B164C),
                initialValue: planId,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Subscription Plan', labelStyle: TextStyle(color: Color(0xFF9E9AC2))),
                items: const [
                  DropdownMenuItem(value: 'free', child: Text('Free (Starter)')),
                  DropdownMenuItem(value: 'pro', child: Text('Pro Coach')),
                  DropdownMenuItem(value: 'enterprise', child: Text('Executive Mastery (Enterprise)')),
                ],
                onChanged: (val) => planId = val!,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDialogTextField(streakCtrl, 'Streak (Days)')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDialogTextField(xpCtrl, 'Total XP')),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E9AC2)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryCoral),
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                final payload = {
                  'name': nameCtrl.text,
                  'email': emailCtrl.text,
                  'role': role,
                  'current_plan_id': planId,
                  'streak_days': int.tryParse(streakCtrl.text) ?? 1,
                  'total_xp': int.tryParse(xpCtrl.text) ?? 100,
                };

                if (user == null) {
                  final res = await _apiService.createAdminUser(payload);
                  final newUser = res != null ? AdminUserItem.fromJson(res) : AdminUserItem(
                    id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text,
                    email: emailCtrl.text,
                    role: role,
                    streakDays: int.tryParse(streakCtrl.text) ?? 1,
                    totalXP: int.tryParse(xpCtrl.text) ?? 100,
                    planId: planId,
                  );
                  setState(() => _users.insert(0, newUser));
                  _showNotification('User "${nameCtrl.text}" created successfully');
                } else {
                  await _apiService.updateAdminUser(user.id, payload);
                  setState(() {
                    user.name = nameCtrl.text;
                    user.email = emailCtrl.text;
                    user.role = role;
                    user.planId = planId;
                    user.streakDays = int.tryParse(streakCtrl.text) ?? user.streakDays;
                    user.totalXP = int.tryParse(xpCtrl.text) ?? user.totalXP;
                  });
                  _showNotification('User "${nameCtrl.text}" updated successfully');
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(user == null ? 'Create' : 'Save', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openSkillRuleDialog({SkillRuleItem? rule}) {
    final titleCtrl = TextEditingController(text: rule?.title ?? '');
    final focusCtrl = TextEditingController(text: rule?.focusArea ?? '');
    final minScoreCtrl = TextEditingController(text: rule != null ? rule.minScoreThreshold.toString() : '80');
    final maxFillersCtrl = TextEditingController(text: rule != null ? rule.maxFillerWords.toString() : '2');
    final tipCtrl = TextEditingController(text: rule?.guidanceTip ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161344),
        title: Text(rule == null ? 'Create Skill Rule' : 'Edit Skill Rule', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(titleCtrl, 'Rule Title'),
              const SizedBox(height: 12),
              _buildDialogTextField(focusCtrl, 'Focus Area (e.g. Speaking Pace)'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDialogTextField(minScoreCtrl, 'Min Score (%)')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDialogTextField(maxFillersCtrl, 'Max Fillers')),
                ],
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(tipCtrl, 'Actionable Guidance Tip'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E9AC2)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryCoral),
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty) {
                final payload = {
                  'title': titleCtrl.text,
                  'focus_area': focusCtrl.text,
                  'min_score_threshold': int.tryParse(minScoreCtrl.text) ?? 80,
                  'max_filler_words': int.tryParse(maxFillersCtrl.text) ?? 2,
                  'guidance_tip': tipCtrl.text,
                };

                if (rule == null) {
                  final res = await _apiService.createSkillRule(payload);
                  final newRule = res != null ? SkillRuleItem.fromJson(res) : SkillRuleItem(
                    id: 'rule_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleCtrl.text,
                    focusArea: focusCtrl.text,
                    minScoreThreshold: int.tryParse(minScoreCtrl.text) ?? 80,
                    maxFillerWords: int.tryParse(maxFillersCtrl.text) ?? 2,
                    guidanceTip: tipCtrl.text,
                  );
                  setState(() => _skillRules.add(newRule));
                  _showNotification('Skill Rule "${titleCtrl.text}" created');
                } else {
                  await _apiService.updateSkillRule(rule.id, payload);
                  setState(() {
                    rule.title = titleCtrl.text;
                    rule.focusArea = focusCtrl.text;
                    rule.minScoreThreshold = int.tryParse(minScoreCtrl.text) ?? rule.minScoreThreshold;
                    rule.maxFillerWords = int.tryParse(maxFillersCtrl.text) ?? rule.maxFillerWords;
                    rule.guidanceTip = tipCtrl.text;
                  });
                  _showNotification('Skill Rule "${titleCtrl.text}" updated');
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(rule == null ? 'Create' : 'Save', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openRoadmapDialog({RoadmapStageItem? stage}) {
    final titleCtrl = TextEditingController(text: stage?.title ?? '');
    final envNameCtrl = TextEditingController(text: stage?.environmentName ?? '');
    final emojiCtrl = TextEditingController(text: stage?.environmentEmoji ?? '🎤');
    final promptCtrl = TextEditingController(text: stage?.situationPrompt ?? '');
    final durationCtrl = TextEditingController(text: stage != null ? stage.durationSeconds.toString() : '60');
    final xpCtrl = TextEditingController(text: stage != null ? stage.xpReward.toString() : '100');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161344),
        title: Text(stage == null ? 'Create Roadmap Stage' : 'Edit Roadmap Stage', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(titleCtrl, 'Stage Title'),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(width: 80, child: _buildDialogTextField(emojiCtrl, 'Emoji')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDialogTextField(envNameCtrl, 'Environment (e.g. TEDx Stage)')),
                ],
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(promptCtrl, 'Situation Prompt / Mission'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDialogTextField(durationCtrl, 'Duration (s)')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDialogTextField(xpCtrl, 'XP Reward')),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E9AC2)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryCoral),
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty) {
                final payload = {
                  'title': titleCtrl.text,
                  'environment_name': envNameCtrl.text,
                  'environment_emoji': emojiCtrl.text,
                  'situation_prompt': promptCtrl.text,
                  'duration_seconds': int.tryParse(durationCtrl.text) ?? 60,
                  'xp_reward': int.tryParse(xpCtrl.text) ?? 100,
                };

                if (stage == null) {
                  final res = await _apiService.createRoadmapStage(payload);
                  final newStage = res != null ? RoadmapStageItem.fromJson(res) : RoadmapStageItem(
                    id: 'stg_${DateTime.now().millisecondsSinceEpoch}',
                    stageNumber: _roadmapStages.length + 1,
                    environmentEmoji: emojiCtrl.text,
                    environmentName: envNameCtrl.text,
                    title: titleCtrl.text,
                    situationPrompt: promptCtrl.text,
                    durationSeconds: int.tryParse(durationCtrl.text) ?? 60,
                    xpReward: int.tryParse(xpCtrl.text) ?? 100,
                  );
                  setState(() => _roadmapStages.add(newStage));
                  _showNotification('Roadmap Stage "${titleCtrl.text}" created');
                } else {
                  await _apiService.updateRoadmapStage(stage.id, payload);
                  setState(() {
                    stage.title = titleCtrl.text;
                    stage.environmentName = envNameCtrl.text;
                    stage.environmentEmoji = emojiCtrl.text;
                    stage.situationPrompt = promptCtrl.text;
                    stage.durationSeconds = int.tryParse(durationCtrl.text) ?? stage.durationSeconds;
                    stage.xpReward = int.tryParse(xpCtrl.text) ?? stage.xpReward;
                  });
                  _showNotification('Roadmap Stage "${titleCtrl.text}" updated');
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(stage == null ? 'Create' : 'Save', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openExerciseDialog({ExerciseItem? exercise}) {
    final titleCtrl = TextEditingController(text: exercise?.title ?? '');
    final catCtrl = TextEditingController(text: exercise?.categoryId ?? 'General');
    final coachCtrl = TextEditingController(text: exercise?.evaluatorName ?? 'The Coach');
    final durationCtrl = TextEditingController(text: exercise != null ? exercise.targetDurationSeconds.toString() : '60');
    final promptCtrl = TextEditingController(text: exercise?.samplePrompt ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161344),
        title: Text(exercise == null ? 'Create Exercise' : 'Edit Exercise', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(titleCtrl, 'Exercise Title'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDialogTextField(catCtrl, 'Category (e.g. Technology)')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDialogTextField(coachCtrl, 'Evaluator Coach')),
                ],
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(durationCtrl, 'Target Duration (s)'),
              const SizedBox(height: 12),
              _buildDialogTextField(promptCtrl, 'Sample Speaking Prompt'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E9AC2)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryCoral),
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty) {
                final payload = {
                  'title': titleCtrl.text,
                  'category_id': catCtrl.text,
                  'evaluator_name': coachCtrl.text,
                  'target_duration_seconds': int.tryParse(durationCtrl.text) ?? 60,
                  'sample_prompt': promptCtrl.text,
                };

                if (exercise == null) {
                  final res = await _apiService.createExercise(payload);
                  final newEx = res != null ? ExerciseItem.fromJson(res) : ExerciseItem(
                    id: 'ex_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleCtrl.text,
                    categoryId: catCtrl.text,
                    evaluatorName: coachCtrl.text,
                    targetDurationSeconds: int.tryParse(durationCtrl.text) ?? 60,
                    samplePrompt: promptCtrl.text,
                  );
                  setState(() => _exercises.add(newEx));
                  _showNotification('Exercise "${titleCtrl.text}" created');
                } else {
                  await _apiService.updateExercise(exercise.id, payload);
                  setState(() {
                    exercise.title = titleCtrl.text;
                    exercise.categoryId = catCtrl.text;
                    exercise.evaluatorName = coachCtrl.text;
                    exercise.targetDurationSeconds = int.tryParse(durationCtrl.text) ?? exercise.targetDurationSeconds;
                    exercise.samplePrompt = promptCtrl.text;
                  });
                  _showNotification('Exercise "${titleCtrl.text}" updated');
                }
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(exercise == null ? 'Create' : 'Save', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String itemType, String name, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161344),
        title: Text('Delete $itemType', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "$name"? This action will permanently remove it from the database.', style: const TextStyle(color: Color(0xFF9E9AC2))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF9E9AC2)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryCoral),
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9E9AC2), fontSize: 12),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2B246A))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryPurple)),
        filled: true,
        fillColor: const Color(0xFF131038),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
