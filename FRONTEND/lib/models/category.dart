import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CategoryItem {
  final String id;
  final String title;
  final String emoji;
  final Color cardColor;
  final List<String> sampleTopics;

  const CategoryItem({
    required this.id,
    required this.title,
    required this.emoji,
    required this.cardColor,
    required this.sampleTopics,
  });

  static List<CategoryItem> categories = [
    CategoryItem(
      id: 'tech',
      title: 'Technology',
      emoji: '💻',
      cardColor: AppColors.primaryBlue,
      sampleTopics: [
        'Should artificial intelligence replace some entry-level jobs?',
        'How quantum computing will transform cybersecurity.',
        'Explaining blockchain technology to non-technical users.'
      ],
    ),
    CategoryItem(
      id: 'law',
      title: 'Law & Justice',
      emoji: '⚖️',
      cardColor: Color(0xFF7C3AED),
      sampleTopics: [
        'Defending digital privacy in the age of big data.',
        'The ethics of autonomous vehicle liability.',
        'Presenting a closing argument in a mock trial.'
      ],
    ),
    CategoryItem(
      id: 'management',
      title: 'Management',
      emoji: '📊',
      cardColor: AppColors.secondaryTeal,
      sampleTopics: [
        'Handling remote team conflicts productively.',
        'Pitching a quarterly budget increase to stakeholders.',
        'Communicating organizational restructuring with empathy.'
      ],
    ),
    CategoryItem(
      id: 'general_knowledge',
      title: 'General Knowledge',
      emoji: '🌐',
      cardColor: Color(0xFF0284C7),
      sampleTopics: [
        'Why space exploration matters for humanity on Earth.',
        'The origin and future of global renewable energy.',
        'How urbanization affects local ecosystems.'
      ],
    ),
    CategoryItem(
      id: 'psychology',
      title: 'Psychology',
      emoji: '🧠',
      cardColor: Color(0xFFDB2777),
      sampleTopics: [
        'Overcoming cognitive bias in personal decision making.',
        'The science of habit formation and willpower.',
        'Understanding non-verbal micro-expressions.'
      ],
    ),
    CategoryItem(
      id: 'leadership',
      title: 'Leadership',
      emoji: '👑',
      cardColor: AppColors.motivationCoral,
      sampleTopics: [
        'Inspiring a team during times of crisis and uncertainty.',
        'Servant leadership versus command-and-control.',
        'How to deliver tough constructive feedback.'
      ],
    ),
    CategoryItem(
      id: 'personal_development',
      title: 'Personal Development',
      emoji: '🌱',
      cardColor: AppColors.successGreen,
      sampleTopics: [
        'Building daily resilience in high-stress environments.',
        'The art of time blocking and deep work focus.',
        'Setting boundaries to protect mental well-being.'
      ],
    ),
    CategoryItem(
      id: 'marketing',
      title: 'Marketing',
      emoji: '🚀',
      cardColor: Color(0xFFEA580C),
      sampleTopics: [
        'Crafting a viral brand narrative on social media.',
        'Positioning a new SaaS product in a crowded market.',
        'Ethical marketing versus manipulative copywriting.'
      ],
    ),
    CategoryItem(
      id: 'social_life',
      title: 'Social Life',
      emoji: '☕',
      cardColor: AppColors.warningAmber,
      sampleTopics: [
        'Making a captivating first impression at networking events.',
        'How to give a memorable wedding or birthday toast.',
        'Navigating small talk into deep meaningful conversation.'
      ],
    ),
    CategoryItem(
      id: 'history',
      title: 'History',
      emoji: '📜',
      cardColor: Color(0xFFD97706),
      sampleTopics: [
        'How historical speeches changed the course of nations.',
        'Lessons from ancient Roman and Greek rhetoric.',
        'The impact of the industrial revolution on modern work.'
      ],
    ),
  ];
}
