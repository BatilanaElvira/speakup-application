import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/speakup_logo.dart';
import 'admin_web_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    const bgDark = Color(0xFF0D0B26);
    const cardDark = Color(0xFF161344);
    const cardBorderDark = Color(0xFF2B246A);

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SPEAKUP ADMIN PORTAL',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Dark Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cardBorderDark),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  const SpeakUpLogoWidget(size: 44, showTagline: false, isLightMode: false),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ADMIN CONTROL CENTER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage user accounts, skill evaluation rules, roadmap stages, and exercise pools in real-time.',
                          style: TextStyle(color: Color(0xFF9E9AC2), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Live Database Sync Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF131038),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2B246A)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.storage_rounded, color: AppColors.secondaryTeal, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Persistence: MySQL & In-Memory Fallback Active',
                    style: TextStyle(color: AppColors.secondaryTeal, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'MANAGEMENT MODULES',
              style: TextStyle(
                color: Color(0xFF9E9AC2),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            _buildAdminTile(
              context,
              tabIndex: 1,
              icon: Icons.people_alt_rounded,
              title: 'Manage User Accounts',
              subtitle: 'View, create, edit, or delete trainee and admin accounts',
              color: AppColors.primaryPurple,
              cardDark: cardDark,
              cardBorderDark: cardBorderDark,
            ),
            const SizedBox(height: 12),
            _buildAdminTile(
              context,
              tabIndex: 2,
              icon: Icons.rule_folder_rounded,
              title: 'Manage Skill Rules',
              subtitle: 'Configure scoring thresholds, filler limits, and advice tips',
              color: AppColors.warningAmber,
              cardDark: cardDark,
              cardBorderDark: cardBorderDark,
            ),
            const SizedBox(height: 12),
            _buildAdminTile(
              context,
              tabIndex: 3,
              icon: Icons.account_tree_rounded,
              title: 'Manage Roadmap Stages',
              subtitle: 'Create, update, or remove environmental roadmap nodes',
              color: const Color(0xFF00A3FF),
              cardDark: cardDark,
              cardBorderDark: cardBorderDark,
            ),
            const SizedBox(height: 12),
            _buildAdminTile(
              context,
              tabIndex: 4,
              icon: Icons.fitness_center_rounded,
              title: 'Manage Exercises & Topics',
              subtitle: 'Configure category exercises and evaluator prompts',
              color: AppColors.secondaryTeal,
              cardDark: cardDark,
              cardBorderDark: cardBorderDark,
            ),

            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.glowShadow(AppColors.primaryPurple),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  provider.toggleUserRole();
                },
                icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
                label: const Text('SWITCH TO TRAINEE MODE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTile(
    BuildContext context, {
    required int tabIndex,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color cardDark,
    required Color cardBorderDark,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminWebScreen(initialTab: tabIndex)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cardBorderDark),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9AC2),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C7C9A)),
          ],
        ),
      ),
    );
  }
}
