import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../services/file_picker_service.dart';
import '../../widgets/botanical_header.dart';
import '../../widgets/speakup_logo.dart';
import '../analysis/past_analysis_history_screen.dart';
import '../subscription/subscription_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BotanicalHeaderDecoration(
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D0B26) : AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'My Profile',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.mainText,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white : AppColors.secondaryText),
              onPressed: () => _openSettingsModal(context, provider),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // Profile Avatar, Name & Dynamic Level Badge
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _openEditProfileDialog(context, provider),
                        child: Stack(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? const Color(0xFF1B164C) : const Color(0xFFFFECE8),
                                border: Border.all(color: provider.userLevelColor, width: 3.0),
                                boxShadow: AppColors.cardShadow,
                              ),
                              child: ClipOval(
                                child: FilePickerService.buildAvatarImageWidget(
                                  provider.userAvatarUrl,
                                  width: 96,
                                  height: 96,
                                  fallbackColor: provider.userLevelColor,
                                  iconSize: 54,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryCoral,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isDark ? const Color(0xFF0D0B26) : AppColors.white, width: 2),
                                  boxShadow: AppColors.cardShadow,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.userName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.mainText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider.userEmail,
                        style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 8),

                      // User Dynamic Level Badge (Beginner -> Intermediate -> Advanced -> Expert)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: provider.userLevelColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: provider.userLevelColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.military_tech_rounded, size: 16, color: provider.userLevelColor),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.userLevel.toUpperCase()} LEVEL',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: provider.userLevelColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Level Progress Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B164C) : AppColors.white,
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
                                    const Text('⚡ Experience Points:', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${provider.totalXP} XP',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: isDark ? Colors.white : AppColors.mainText,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Next: ${provider.nextLevelName} (${provider.nextLevelTargetXP} XP)',
                                  style: TextStyle(fontSize: 11, color: provider.userLevelColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: provider.levelProgressPercent,
                                minHeight: 8,
                                backgroundColor: isDark ? const Color(0xFF131038) : AppColors.surfaceLight,
                                valueColor: AlwaysStoppedAnimation<Color>(provider.userLevelColor),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ALL-TIME CAREER SCORES & REGISTRATION TELEMETRY
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? const LinearGradient(
                                  colors: [Color(0xFF1B164C), Color(0xFF131038)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : const LinearGradient(
                                  colors: [Color(0xFFFFF7F5), Color(0xFFF3F2FD)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isDark ? const Color(0xFF2B246A) : const Color(0xFFFFD5CC)),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.workspace_premium_rounded, color: AppColors.primaryCoral, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ALL-TIME SCORES SINCE REGISTRATION',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : AppColors.mainText,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF231D5E) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Joined: Sep 2026',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? const Color(0xFF9E8EFF) : AppColors.secondaryText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // 4-Grid of All-Time Statistics
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatMiniTile(
                                    label: 'Total Scores Sum',
                                    value: '${provider.allTimeScoresTotal} pts',
                                    icon: Icons.stars_rounded,
                                    color: AppColors.primaryCoral,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildStatMiniTile(
                                    label: 'Lifetime Average',
                                    value: '${provider.lifetimeAverageScore.toStringAsFixed(1)}/100',
                                    icon: Icons.analytics_rounded,
                                    color: AppColors.primaryPurple,
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatMiniTile(
                                    label: 'Speeches Analyzed',
                                    value: '${provider.totalPracticesCount} sessions',
                                    icon: Icons.mic_external_on_rounded,
                                    color: AppColors.secondaryTeal,
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildStatMiniTile(
                                    label: 'Personal Best',
                                    value: '${provider.highestSessionScore}/100',
                                    icon: Icons.emoji_events_rounded,
                                    color: AppColors.warningAmber,
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                const SizedBox(height: 20),

                // Profile Menu Options List
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B164C) : AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.history_rounded,
                        label: 'Past Speech Evaluations',
                        isDark: isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PastAnalysisHistoryScreen()),
                          );
                        },
                      ),
                      Divider(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder, height: 1),
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profile',
                        isDark: isDark,
                        onTap: () => _openEditProfileDialog(context, provider),
                      ),
                      Divider(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder, height: 1),
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings (Audio & Feedback)',
                        isDark: isDark,
                        onTap: () => _openSettingsModal(context, provider),
                      ),
                      Divider(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder, height: 1),
                      _buildMenuItem(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Subscription',
                        isDark: isDark,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF131038) : AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${provider.currentPlan.title} (${provider.currentPlan.monthlyPrice}) >',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF9E8EFF) : AppColors.secondaryText,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                          );
                        },
                      ),
                      Divider(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder, height: 1),
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        isDark: isDark,
                        onTap: () => _openHelpModal(context),
                      ),
                      Divider(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder, height: 1),
                      _buildMenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'About SpeakUp',
                        isDark: isDark,
                        onTap: () => _openAboutModal(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Log Out Button
                TextButton(
                  onPressed: () {
                    provider.logout();
                  },
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.errorRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required bool isDark,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isDark ? const Color(0xFF9E8EFF) : AppColors.mainText, size: 20),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.mainText,
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF7C7C9A) : AppColors.secondaryText,
              size: 20,
            ),
      ),
    );
  }

  // --- 1. EDIT PROFILE MODAL ---
  void _openEditProfileDialog(BuildContext context, AppProvider provider) {
    final nameCtrl = TextEditingController(text: provider.userName);
    final emailCtrl = TextEditingController(text: provider.userEmail);
    final presets = provider.avatarPresets;
    String selectedAvatarUrl = provider.userAvatarUrl ?? (presets.isNotEmpty ? presets[0]['url']! : '');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF161344) : AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                const Text('📷 ', style: TextStyle(fontSize: 20)),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.mainText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Picture Live Preview
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF1B164C) : const Color(0xFFFFECE8),
                              border: Border.all(color: AppColors.primaryCoral, width: 2.5),
                              boxShadow: AppColors.cardShadow,
                            ),
                            child: ClipOval(
                              child: FilePickerService.buildAvatarImageWidget(
                                selectedAvatarUrl,
                                width: 88,
                                height: 88,
                                fallbackColor: AppColors.primaryCoral,
                                iconSize: 48,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.secondaryTeal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Choose Image from Gallery Button
                    Center(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.photo_library_rounded, size: 18),
                        label: const Text(
                          'CHOOSE FROM GALLERY / PHOTOS',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryCoral,
                          side: const BorderSide(color: AppColors.primaryCoral, width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final imageBase64 = await FilePickerService.instance.pickProfileImageFromGallery();
                          if (imageBase64 != null) {
                            setState(() {
                              selectedAvatarUrl = imageBase64;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Database Stored Presets Selection
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primaryCoral),
                        const SizedBox(width: 6),
                        Text(
                          'DATABASE AVATAR PRESETS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF9E9AC2) : AppColors.secondaryText,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 64,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: presets.length,
                        separatorBuilder: (context, i) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final preset = presets[index];
                          final presetUrl = preset['url']?.toString() ?? '';
                          final isSelected = selectedAvatarUrl == presetUrl;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAvatarUrl = presetUrl;
                              });
                            },
                            child: Tooltip(
                              message: preset['label']?.toString() ?? 'Speaker',
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryCoral : (isDark ? const Color(0xFF2B246A) : AppColors.cardBorder),
                                    width: isSelected ? 3.0 : 1.5,
                                  ),
                                  boxShadow: isSelected ? AppColors.glowShadow(AppColors.primaryCoral) : null,
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    presetUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 28),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),

                    const SizedBox(height: 16),

                    // Full Name Input
                    TextField(
                      controller: nameCtrl,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.mainText),
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                        labelStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9E9AC2) : AppColors.secondaryText),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1F1B52) : AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Email Input
                    TextField(
                      controller: emailCtrl,
                      style: TextStyle(color: isDark ? Colors.white : AppColors.mainText),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined, size: 18),
                        labelStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9E9AC2) : AppColors.secondaryText),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1F1B52) : AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : AppColors.secondaryText)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCoral,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                    await provider.updateProfile(
                      name: nameCtrl.text.trim(),
                      email: emailCtrl.text.trim(),
                      avatarUrl: selectedAvatarUrl.isNotEmpty ? selectedAvatarUrl : null,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile & Picture updated successfully!'),
                          backgroundColor: AppColors.secondaryTeal,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 2. SETTINGS (AUDIO VOLUME & FEEDBACK) MODAL ---
  void _openSettingsModal(BuildContext context, AppProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161344) : AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Audio & Feedback Settings',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.mainText),
                        ),
                        IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Audio Feedback & Ambient Volume Slider
                    Text('Audio Feedback & Ambient Volume', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.mainText)),
                    const SizedBox(height: 4),
                    const Text('Adjust simulated sound volume and feedback voice guidance level', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.volume_down_rounded, color: AppColors.secondaryText),
                        Expanded(
                          child: Slider(
                            value: provider.audioVolume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            activeColor: AppColors.primaryPurple,
                            label: '${(provider.audioVolume * 100).toInt()}%',
                            onChanged: (val) {
                              provider.setAudioVolume(val);
                              setModalState(() {});
                            },
                          ),
                        ),
                        const Icon(Icons.volume_up_rounded, color: AppColors.secondaryText),
                      ],
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Volume: ${(provider.audioVolume * 100).toInt()}%',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- 3. HELP & SUPPORT MODAL ---
  void _openHelpModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF161344) : AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Help & Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.mainText)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 14),
                _buildFaqItem('How does SpeakUp score my speech?', 'Our AI evaluates clarity, vocal pace, filler words, argument structure, and executive presence.', isDark),
                _buildFaqItem('How do I level up from Beginner to Expert?', 'Earn XP by completing journey exercises, quick practice sessions, and reading daily knowledge briefs.', isDark),
                _buildFaqItem('Can I practice in simulated environments?', 'Yes! Enable simulated environments in the practice studio to train for meeting rooms, TEDx stages, or thesis defenses.', isDark),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Support ticket created. Our team will contact you shortly!'), backgroundColor: AppColors.secondaryTeal),
                      );
                    },
                    icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
                    label: const Text('Contact 24/7 Human Coach Support', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple, padding: const EdgeInsets.symmetric(vertical: 14)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaqItem(String question, String answer, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Q: $question', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.mainText)),
          const SizedBox(height: 2),
          Text(answer, style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
        ],
      ),
    );
  }

  // --- 4. ABOUT SPEAKUP MODAL ---
  void _openAboutModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161344) : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.primaryCoral),
            const SizedBox(width: 8),
            Text(
              'About SpeakUp',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.mainText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SpeakUpLogoWidget(size: 80, showTagline: true),
              const SizedBox(height: 16),
              Text(
                'SpeakUp — AI Public Speaking Coach',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.mainText,
                ),
              ),
              const SizedBox(height: 4),
              const Text('Version 2.4.0 (Build 2026)', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
              const SizedBox(height: 12),
              Text(
                'SpeakUp empowers individuals to speak with confidence, clarity, and authority through simulated environment practice and real-time AI speech analysis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark ? Colors.white70 : AppColors.mainText,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Architecture: MVC & N-Tier\nDatabase: MySQL Persistent Engine',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: isDark ? Colors.white70 : AppColors.secondaryText)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatMiniTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161344) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF2B246A) : const Color(0xFFFFECE8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: isDark ? Colors.white : AppColors.mainText,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFF9E9AC2) : AppColors.secondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

