import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/simulated_environment.dart';
import '../../models/subscription_plan.dart';
import '../../providers/app_provider.dart';
import '../practice/evaluator_selector.dart';
import '../subscription/payment_checkout_modal.dart';

class SimulatedEnvironmentScreen extends StatelessWidget {
  const SimulatedEnvironmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isEnabled = provider.isSimulatedEnvironmentEnabled;
    final currentEnv = provider.selectedEnvironment;
    final currentEvaluator = provider.selectedEvaluator;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.mainText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SIMULATED ENVIRONMENT & LOGIC',
          style: TextStyle(
            color: AppColors.mainText,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 0.8,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. MASTER TOGGLE: Put Simulation Mode when Practicing or Not
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isEnabled
                      ? AppColors.primaryGradient
                      : LinearGradient(
                          colors: [AppColors.secondaryText.withValues(alpha: 0.7), AppColors.mainText],
                        ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isEnabled
                      ? AppColors.glowShadow(AppColors.primaryBlue)
                      : AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(isEnabled ? currentEnv.emoji : '⚡', style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isEnabled
                                        ? AppColors.white.withValues(alpha: 0.25)
                                        : Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isEnabled ? 'SIMULATION ACTIVE' : 'CLEAN STUDIO MODE',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isEnabled ? currentEnv.title : 'Pure Focus Studio',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: isEnabled,
                          activeThumbColor: AppColors.white,
                          activeTrackColor: AppColors.secondaryTeal,
                          inactiveThumbColor: AppColors.white,
                          inactiveTrackColor: Colors.white30,
                          onChanged: (val) => provider.toggleSimulatedEnvironmentEnabled(val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isEnabled
                          ? 'Trainees can practice with immersive background acoustics, realistic audience dynamics, and evaluator-tailored criteria.'
                          : 'Simulation disabled. You will practice in a quiet, distraction-free environment focused solely on vocal audio analysis.',
                      style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. AI EVALUATOR & LOGIC OF EVALUATION
              const Text(
                'AI EVALUATOR & SCORING LOGIC',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.cardShadow,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: currentEvaluator.accentColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(currentEvaluator.icon, style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentEvaluator.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.mainText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentEvaluator.title,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: currentEvaluator.accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const EvaluatorSelectorModal(),
                            );
                          },
                          child: const Text(
                            'Switch Evaluator',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.cardBorder, height: 1),
                    const SizedBox(height: 14),
                    const Text(
                      'Logic of Evaluation & Key Metrics:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentEnv.evaluatorLogicDescription,
                      style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentEnv.evaluationCriteria.map((criterion) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: currentEvaluator.accentColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: currentEvaluator.accentColor.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 14, color: currentEvaluator.accentColor),
                              const SizedBox(width: 6),
                              Text(
                                criterion,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: currentEvaluator.accentColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3. EVALUATOR STRICTNESS & PERSONA SELECTOR
              const Text(
                'EVALUATOR STRICTNESS & PERSONA',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: ['Supportive', 'Balanced', 'Strict Jury', 'High Pressure'].map((mode) {
                  final isSelected = provider.simulationStrictness == mode;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => provider.setSimulationStrictness(mode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryBlue : AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryBlue : AppColors.cardBorder,
                          ),
                          boxShadow: isSelected ? AppColors.glowShadow(AppColors.primaryBlue) : AppColors.cardShadow,
                        ),
                        child: Text(
                          mode,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.white : AppColors.mainText,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // 4. CHOOSE SIMULATED SETTING
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SIMULATED ENVIRONMENT SETTINGS',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (!isEnabled)
                    const Text(
                      'Enable above to activate',
                      style: TextStyle(fontSize: 11, color: AppColors.primaryCoral, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: SimulatedEnvironment.environments.length,
                itemBuilder: (context, index) {
                  final env = SimulatedEnvironment.environments[index];
                  final isSelected = currentEnv.id == env.id;
                  final isRecommended = env.recommendedEvaluatorId == currentEvaluator.id;
                  final isAllowed = provider.isEnvironmentAllowed(env);
                  final isPlusRequired = env.id == 'courtroom' || env.id == 'university_hall';

                  return GestureDetector(
                    onTap: isEnabled
                        ? () {
                            if (isAllowed) {
                              provider.selectEnvironment(env);
                            } else {
                              final targetPlan = isPlusRequired ? SubscriptionPlan.plans[2] : SubscriptionPlan.plans[1];
                              PaymentCheckoutModal.show(context, targetPlan);
                            }
                          }
                        : null,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isEnabled ? (isAllowed ? 1.0 : 0.75) : 0.5,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isAllowed ? AppColors.white : const Color(0xFFF9F9FB),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isSelected && isEnabled
                              ? AppColors.glowShadow(AppColors.primaryBlue)
                              : AppColors.cardShadow,
                          border: Border.all(
                            color: isSelected && isEnabled
                                ? AppColors.primaryBlue
                                : (!isAllowed ? const Color(0xFFE2E0EE) : AppColors.cardBorder),
                            width: isSelected && isEnabled ? 2.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected && isEnabled
                                        ? AppColors.primaryBlue.withValues(alpha: 0.12)
                                        : AppColors.background,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(env.emoji, style: const TextStyle(fontSize: 26)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              env.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: isAllowed ? AppColors.mainText : Colors.grey.shade700,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (!isAllowed) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: isPlusRequired
                                                    ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                                                    : AppColors.primaryCoral.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.lock_rounded,
                                                    size: 10,
                                                    color: isPlusRequired ? const Color(0xFF8B5CF6) : AppColors.primaryCoral,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    isPlusRequired ? 'PLUS' : 'PRO',
                                                    style: TextStyle(
                                                      color: isPlusRequired ? const Color(0xFF8B5CF6) : AppColors.primaryCoral,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.w900,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ] else if (isRecommended) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.successGreen.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                'RECOMMENDED',
                                                style: TextStyle(
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.successGreen,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        isAllowed
                                            ? env.subtitle
                                            : 'Locked on Free Plan. Tap to activate ${isPlusRequired ? 'Executive Plus' : 'Pro Speaker'} plan.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isAllowed ? AppColors.secondaryText : AppColors.primaryCoral,
                                          fontWeight: isAllowed ? FontWeight.normal : FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected && isEnabled) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 24),
                                ] else if (!isAllowed) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.lock_outline_rounded, color: AppColors.secondaryText, size: 20),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.volume_up_rounded, size: 13, color: AppColors.primaryBlue),
                                      const SizedBox(width: 4),
                                      Text(
                                        env.ambientSoundName,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryCoral.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    env.pressureLevel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primaryCoral,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // 5. SIMULATION PARAMETER TOGGLES
              const Text(
                'ACOUSTIC & AUDIENCE DYNAMICS',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: provider.enableAmbientAudio && isEnabled,
                        activeThumbColor: AppColors.white,
                        activeTrackColor: AppColors.primaryBlue,
                        title: const Text(
                          'Ambient Acoustic Sound Effects',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.mainText),
                        ),
                        subtitle: Text(
                          currentEnv.ambientSoundName,
                          style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                        ),
                        onChanged: isEnabled ? (val) => provider.toggleAmbientAudio(val) : null,
                      ),
                      const Divider(color: AppColors.cardBorder, height: 1),
                      SwitchListTile(
                        value: provider.enableAudienceReactions && isEnabled,
                        activeThumbColor: AppColors.white,
                        activeTrackColor: AppColors.primaryBlue,
                        title: const Text(
                          'Live Audience Reactions & Interjections',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.mainText),
                        ),
                        subtitle: const Text(
                          'Simulates crowd murmurs, nodding, and evaluator objections',
                          style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                        ),
                        onChanged: isEnabled ? (val) => provider.toggleAudienceReactions(val) : null,
                      ),
                      const Divider(color: AppColors.cardBorder, height: 1),
                      SwitchListTile(
                        value: provider.enablePressureTimer && isEnabled,
                        activeThumbColor: AppColors.white,
                        activeTrackColor: AppColors.primaryBlue,
                        title: const Text(
                          'Pacing & Countdown Pressure Timer',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.mainText),
                        ),
                        subtitle: const Text(
                          'Alerts when exceeding target time for executive pitches',
                          style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                        ),
                        onChanged: isEnabled ? (val) => provider.togglePressureTimer(val) : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // 6. APPLY & SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEnabled
                              ? 'Simulated environment (${currentEnv.title}) applied!'
                              : 'Clean studio mode enabled for practice.',
                        ),
                        backgroundColor: AppColors.primaryBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                  label: Text(
                    isEnabled ? 'SAVE & START IN ${currentEnv.title.toUpperCase()}' : 'SAVE & PRACTICE IN CLEAN STUDIO',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
