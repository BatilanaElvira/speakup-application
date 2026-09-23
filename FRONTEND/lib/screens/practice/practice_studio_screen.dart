import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/subscription_plan.dart';
import '../../providers/app_provider.dart';
import '../../services/file_picker_service.dart';
import '../environment/environment_selector_screen.dart';
import '../subscription/payment_checkout_modal.dart';
import 'evaluator_selector.dart';
import 'interactive_qa_studio.dart';
import 'topic_selection_screen.dart';
import 'video_recording_studio_screen.dart';

class PracticeStudioScreen extends StatefulWidget {
  final String? initialTopic;
  final String? nodeId;

  const PracticeStudioScreen({super.key, this.initialTopic, this.nodeId});

  @override
  State<PracticeStudioScreen> createState() => _PracticeStudioScreenState();
}

class _PracticeStudioScreenState extends State<PracticeStudioScreen> {
  bool _videoRecording = false;
  bool _audioRecording = true;
  final TextEditingController _documentContextController = TextEditingController();
  String? _attachedFileName;

  @override
  void initState() {
    super.initState();
    if (widget.initialTopic != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AppProvider>(context, listen: false).setTopic(widget.initialTopic!);
      });
    }
  }

  void _showDocumentContextModal() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (!provider.canAccessDocumentContext) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 Speech Document Context is available on Pro Speaker & Executive Plus plans.'),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
      PaymentCheckoutModal.show(context, SubscriptionPlan.plans[1]);
      return;
    }
    _documentContextController.text = provider.speechDocumentContext ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '📄 Add Report / Speech Context',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.mainText),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Select a report from your document folder or paste your draft so the AI Evaluator analyzes your exact material.',
                        style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 16),

                      // Document Picker Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.folder_open_rounded, size: 18, color: AppColors.primaryBlue),
                              label: const Text('PICK FROM DOCUMENTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryBlue,
                                side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              onPressed: () async {
                                final doc = await FilePickerService.instance.pickReportDocument();
                                if (doc != null) {
                                  setModalState(() {
                                    _attachedFileName = doc.fileName;
                                    _documentContextController.text = doc.content;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (_documentContextController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.errorRed),
                              tooltip: 'Clear Document Context',
                              onPressed: () {
                                setModalState(() {
                                  _attachedFileName = null;
                                  _documentContextController.clear();
                                });
                              },
                            ),
                        ],
                      ),

                      if (_attachedFileName != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Attached: $_attachedFileName',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Sample Reports Quick Selector
                      const Text(
                        'OR SELECT PRELOADED REPORT TEMPLATE:',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondaryText, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: FilePickerService.sampleReports.length,
                          separatorBuilder: (context, i) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final sample = FilePickerService.sampleReports[index];
                            return ActionChip(
                              backgroundColor: AppColors.background,
                              side: const BorderSide(color: AppColors.cardBorder),
                              label: Text(sample['title']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              onPressed: () {
                                setModalState(() {
                                  _attachedFileName = sample['title'];
                                  _documentContextController.text = sample['summary']!;
                                });
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Document Text Area
                      TextField(
                        controller: _documentContextController,
                        maxLines: 5,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Report context text will appear here or paste directly...',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.cardBorder),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final text = _documentContextController.text.trim();
                            provider.setSpeechDocumentContext(text.isNotEmpty ? text : null);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  text.isNotEmpty ? 'Report context attached for AI Evaluator!' : 'Document context cleared.',
                                ),
                                backgroundColor: AppColors.secondaryTeal,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('SEND REPORT TO EVALUATOR', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    // Centered AI Analyzing Screen
    if (provider.isAnalyzing) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppColors.glowShadow(AppColors.primaryBlue),
                ),
                child: const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${provider.selectedEvaluator.name} is Analyzing...',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mainText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Evaluating pace, clarity, & matching reading recommendations...',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'PRACTICE STUDIO SETUP',
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Session Configuration',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.mainText,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Customize your topic, evaluator, document context, and environment.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 20),

              // Selected Topic Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PRACTICE TOPIC',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TopicSelectionScreen()),
                            );
                          },
                          child: const Text(
                            'Change Topic ➔',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      provider.currentTopic,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mainText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Choose Evaluator Card
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const EvaluatorSelectorModal(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(provider.selectedEvaluator.icon, style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI EVALUATOR COACH',
                              style: TextStyle(fontSize: 10, color: AppColors.secondaryText, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              provider.selectedEvaluator.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.mainText),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.swap_horiz_rounded, color: AppColors.primaryBlue),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Choose / Toggle Simulated Environment Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EnvironmentSelectorScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: provider.isSimulatedEnvironmentEnabled
                        ? AppColors.glowShadow(AppColors.primaryBlue)
                        : AppColors.cardShadow,
                    border: Border.all(
                      color: provider.isSimulatedEnvironmentEnabled ? AppColors.primaryBlue : AppColors.cardBorder,
                      width: provider.isSimulatedEnvironmentEnabled ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: provider.isSimulatedEnvironmentEnabled
                              ? AppColors.primaryBlue.withValues(alpha: 0.12)
                              : AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          provider.isSimulatedEnvironmentEnabled ? provider.selectedEnvironment.emoji : '⚡',
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'SIMULATED ENVIRONMENT',
                                  style: TextStyle(fontSize: 10, color: AppColors.secondaryText, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: provider.isSimulatedEnvironmentEnabled
                                        ? AppColors.successGreen.withValues(alpha: 0.15)
                                        : AppColors.secondaryText.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    provider.isSimulatedEnvironmentEnabled ? 'ON' : 'OFF',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: provider.isSimulatedEnvironmentEnabled ? AppColors.successGreen : AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              provider.isSimulatedEnvironmentEnabled
                                  ? provider.selectedEnvironment.title
                                  : 'Clean Minimal Studio',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.mainText),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: provider.isSimulatedEnvironmentEnabled,
                        activeThumbColor: AppColors.white,
                        activeTrackColor: AppColors.primaryBlue,
                        onChanged: (val) => provider.toggleSimulatedEnvironmentEnabled(val),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Attach Speech Document Context Card
              GestureDetector(
                onTap: _showDocumentContextModal,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: provider.speechDocumentContext != null
                        ? AppColors.successGreen.withValues(alpha: 0.1)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(
                      color: provider.speechDocumentContext != null ? AppColors.successGreen : AppColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('📄 ', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'SPEECH DOCUMENT CONTEXT',
                                  style: TextStyle(fontSize: 10, color: AppColors.secondaryText, fontWeight: FontWeight.bold),
                                ),
                                if (!provider.canAccessDocumentContext) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      '🔒 PRO',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              provider.speechDocumentContext != null
                                  ? 'Document Attached (${provider.speechDocumentContext!.length} chars)'
                                  : (!provider.canAccessDocumentContext ? 'Unlock Report / Document Context (Pro)' : 'Attach Report / Speech Text (Optional)'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: provider.speechDocumentContext != null
                                    ? AppColors.successGreen
                                    : AppColors.mainText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        provider.speechDocumentContext != null
                            ? Icons.check_circle_rounded
                            : (!provider.canAccessDocumentContext ? Icons.lock_outline_rounded : Icons.add_circle_outline_rounded),
                        color: provider.speechDocumentContext != null
                            ? AppColors.successGreen
                            : (!provider.canAccessDocumentContext ? AppColors.primaryBlue : AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Audio vs Video Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Video Mode (Camera & Facial AI)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.mainText),
                            ),
                            if (!provider.canAccessVideoMode) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  '🔒 PRO',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Switch(
                          value: _videoRecording,
                          activeThumbColor: AppColors.primaryBlue,
                          onChanged: (val) {
                            if (val && !provider.canAccessVideoMode) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🔒 HD Video & Facial AI analysis is unlocked on Pro Speaker (3,500 FCFA) and Executive Plus.'),
                                  backgroundColor: AppColors.primaryBlue,
                                ),
                              );
                              PaymentCheckoutModal.show(context, SubscriptionPlan.plans[1]);
                              return;
                            }
                            setState(() {
                              _videoRecording = val;
                              _audioRecording = !val;
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.cardBorder, height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Audio Mode (Voice & Pitch AI)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.mainText),
                        ),
                        Switch(
                          value: _audioRecording,
                          activeThumbColor: AppColors.primaryBlue,
                          onChanged: (val) {
                            setState(() {
                              _audioRecording = val;
                              _videoRecording = !val;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Start Recording Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (provider.hasReachedPracticeLimit) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Row(
                            children: [
                              Icon(Icons.lock_clock_rounded, color: AppColors.primaryBlue),
                              SizedBox(width: 8),
                              Text('Daily Limit Reached', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                          content: const Text(
                            'You have reached your Free Plan limit of 3 practices today. Upgrade to Pro Speaker for unlimited daily practice sessions, HD Video, and deep AI diagnostics!',
                            style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryText)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                PaymentCheckoutModal.show(context, SubscriptionPlan.plans[1]);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Upgrade (3,500 FCFA)'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                    if (_videoRecording) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoRecordingStudioScreen(nodeId: widget.nodeId),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InteractiveQAStudioScreen(
                            topic: provider.currentTopic,
                            evaluatorName: provider.selectedEvaluator.name,
                            evaluatorIcon: provider.selectedEvaluator.icon,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
                  label: Text(
                    _videoRecording ? 'START VIDEO RECORDING' : 'START AUDIO RECORDING',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
