import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/botanical_header.dart';
import 'practice_studio_screen.dart';

class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({super.key});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  late AnimationController _dieSpinController;
  final TextEditingController _customTopicController = TextEditingController();

  final List<Map<String, dynamic>> _topics = [
    {'title': 'The power of habits', 'duration': '5 min', 'category': 'Personal'},
    {'title': 'My biggest challenge', 'duration': '5 min', 'category': 'Personal'},
    {'title': 'Social media impact', 'duration': '5 min', 'category': 'Academic'},
    {'title': 'The future of education', 'duration': '5 min', 'category': 'Academic'},
    {'title': 'Leadership qualities', 'duration': '5 min', 'category': 'Business'},
    {'title': 'Remote work ethics', 'duration': '5 min', 'category': 'Business'},
    {'title': 'Digital privacy in the AI era', 'duration': '5 min', 'category': 'Law & Justice'},
    {'title': 'Closing argument mock defense', 'duration': '5 min', 'category': 'Law & Justice'},
    {'title': 'Managing team conflicts under pressure', 'duration': '5 min', 'category': 'Management'},
    {'title': 'Pitching quarterly budget expansion', 'duration': '5 min', 'category': 'Management'},
    {'title': 'Speeches that changed human history', 'duration': '5 min', 'category': 'History'},
    {'title': 'Rhetoric lessons from ancient Rome', 'duration': '5 min', 'category': 'History'},
    {'title': 'Navigating small talk to meaningful connection', 'duration': '5 min', 'category': 'Social'},
    {'title': 'Giving a memorable wedding or birthday toast', 'duration': '5 min', 'category': 'Social'},
  ];

  @override
  void initState() {
    super.initState();
    _dieSpinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _dieSpinController.dispose();
    _customTopicController.dispose();
    super.dispose();
  }

  void _spinDieAndPickRandomTopic(AppProvider provider) {
    _dieSpinController.forward(from: 0.0).then((_) {
      final random = Random();
      final available = _selectedCategory == 'All'
          ? _topics
          : _topics.where((t) => t['category'] == _selectedCategory).toList();

      final picked = (available.isNotEmpty ? available : _topics)[random.nextInt(available.length)];
      provider.setTopic(picked['title']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎲 Selected: "${picked['title']}"'),
          backgroundColor: AppColors.primaryCoral,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _submitCustomTopic(AppProvider provider) {
    final customText = _customTopicController.text.trim();
    if (customText.isNotEmpty) {
      provider.setTopic(customText);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PracticeStudioScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    final categories = [
      'All',
      'Personal',
      'Academic',
      'Business',
      'Law & Justice',
      'Management',
      'History',
      'Social'
    ];

    final filteredTopics = _selectedCategory == 'All'
        ? _topics
        : _topics.where((t) => t['category'] == _selectedCategory).toList();

    return BotanicalHeaderDecoration(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.mainText, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryCoral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Choose Topic',
              style: TextStyle(
                color: AppColors.primaryCoral,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Choose a Topic',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.mainText,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pick a topic, roll the die, or enter custom',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),

                    // Spinning Die Button
                    GestureDetector(
                      onTap: () => _spinDieAndPickRandomTopic(provider),
                      child: RotationTransition(
                        turns: Tween(begin: 0.0, end: 2.0).animate(
                          CurvedAnimation(parent: _dieSpinController, curve: Curves.decelerate),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.cardShadow,
                            border: Border.all(color: AppColors.primaryCoral),
                          ),
                          child: const Text('🎲', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Custom Topic Input Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppColors.cardShadow,
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.edit_note_rounded, color: AppColors.primaryCoral, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _customTopicController,
                          style: const TextStyle(fontSize: 13, color: AppColors.mainText),
                          decoration: const InputDecoration(
                            hintText: 'Enter your own custom topic...',
                            hintStyle: TextStyle(color: AppColors.lightText, fontSize: 12),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _submitCustomTopic(provider),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryCoral, size: 20),
                        onPressed: () => _submitCustomTopic(provider),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Category Filter Pills (Horizontal scrollable)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryCoral : AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryCoral : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.white : AppColors.secondaryText,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 14),

                // Topics List
                Expanded(
                  child: ListView.separated(
                    itemCount: filteredTopics.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final topic = filteredTopics[index];
                      final isSelected = provider.currentTopic == topic['title'];

                      return GestureDetector(
                        onTap: () {
                          provider.setTopic(topic['title']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PracticeStudioScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: AppColors.cardShadow,
                            border: Border.all(
                              color: isSelected ? AppColors.primaryCoral : AppColors.cardBorder,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.eco_rounded,
                                color: AppColors.sageGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  topic['title'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mainText,
                                  ),
                                ),
                              ),
                              Text(
                                topic['duration'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
