import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum SubscriptionTier { free, pro, plus }

class SubscriptionPlan {
  final SubscriptionTier tier;
  final String title;
  final String monthlyPrice;
  final String billingPeriod;
  final String description;
  final Color themeColor;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.tier,
    required this.title,
    required this.monthlyPrice,
    required this.billingPeriod,
    required this.description,
    required this.themeColor,
    required this.features,
    this.isPopular = false,
  });

  static List<SubscriptionPlan> plans = [
    const SubscriptionPlan(
      tier: SubscriptionTier.free,
      title: 'Free Trainee',
      monthlyPrice: '0 FCFA',
      billingPeriod: 'Forever Free',
      description: 'Essential habit building & basic AI speech feedback.',
      themeColor: AppColors.secondaryText,
      features: [
        '3 practice sessions per day',
        'Basic AI speech scores (Clarity & Pace)',
        'Everyday Coach AI evaluator',
        'Access to Stage 1 Journey exercises',
        'Daily General Knowledge Brief',
        '0 FCFA Forever Free',
      ],
    ),
    const SubscriptionPlan(
      tier: SubscriptionTier.pro,
      title: 'Pro Speaker',
      monthlyPrice: '3,500 FCFA',
      billingPeriod: 'per month',
      description: 'Full AI evaluation, video mode & recommended books library.',
      themeColor: AppColors.primaryBlue,
      isPopular: true,
      features: [
        'Unlimited practice sessions',
        'All 8 Specialized AI Evaluators',
        'Audio + HD Video practice studio',
        'Personalized AI Book Recommendations',
        'Saved Feedback Inbox archive',
        'Non-audio written outline & rhetoric drills',
      ],
    ),
    const SubscriptionPlan(
      tier: SubscriptionTier.plus,
      title: 'Executive Plus',
      monthlyPrice: '5,500 FCFA',
      billingPeriod: 'per month',
      description: 'Live AI Audience Q&A, Thesis Defense Jury & Interactive Debate mode.',
      themeColor: Color(0xFF8B5CF6),
      features: [
        'Everything in Pro Speaker Plan',
        '🎓 Thesis Defense Jury evaluator',
        '⚔️ Interactive Debate AI counter-arguments',
        'Live Simulated AI Audience Q&A follow-ups',
        '1-on-1 AI Executive coaching reports',
        'Priority feature updates',
      ],
    ),
  ];
}
