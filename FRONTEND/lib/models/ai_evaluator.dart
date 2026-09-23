import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AIEvaluator {
  final String id;
  final String name;
  final String title;
  final String description;
  final String icon;
  final Color accentColor;
  final String focusArea;
  final List<String> specializedScenarios;
  final String samplePrompt;

  const AIEvaluator({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.focusArea,
    required this.specializedScenarios,
    required this.samplePrompt,
  });

  static List<AIEvaluator> evaluators = [
    const AIEvaluator(
      id: 'coach',
      name: 'The Coach',
      title: 'Everyday speaking practice',
      description: 'Supportive and encouraging guidance for building daily habit and vocal ease.',
      icon: '🎤',
      accentColor: AppColors.secondaryTeal,
      focusArea: 'Natural delivery, vocal ease & daily consistency',
      specializedScenarios: [
        'Everyday conversation introduction',
        'Sharing a personal daily highlight',
        'Explaining an everyday topic simply'
      ],
      samplePrompt: 'Tell me about something exciting you learned today in under 60 seconds.',
    ),
    const AIEvaluator(
      id: 'executive',
      name: 'The Executive',
      title: 'Professional communication',
      description: 'Focuses on conciseness, executive presence, structure, and strategic clarity.',
      icon: '💼',
      accentColor: AppColors.primaryBlue,
      focusArea: 'Executive presence, conciseness & data delivery',
      specializedScenarios: [
        'Job Interview: "Tell me about yourself"',
        'Project Status Update to Senior Leadership',
        'Handling manager objections during a proposal'
      ],
      samplePrompt: 'Briefly present the key metrics and ROI of your recent project.',
    ),
    const AIEvaluator(
      id: 'storyteller',
      name: 'The Storyteller',
      title: 'Storytelling & presentations',
      description: 'Evaluates emotional resonance, narrative structure, hooks, and listener engagement.',
      icon: '🎙️',
      accentColor: AppColors.motivationCoral,
      focusArea: 'Narrative hook, vocal inflection & emotional impact',
      specializedScenarios: [
        'TEDx Style Keynote Hook',
        'Inspiring a team with a personal story',
        'Explaining a vision for the future'
      ],
      samplePrompt: 'Start your presentation with a captivating story or personal anecdote.',
    ),
    const AIEvaluator(
      id: 'advocate',
      name: 'The Advocate',
      title: 'Persuasion & arguments',
      description: 'Sharp analysis of logical arguments, evidence, rebuttal, and persuasive power.',
      icon: '⚖️',
      accentColor: AppColors.warningAmber,
      focusArea: 'Logical coherence, persuasive arguments & rebuttal',
      specializedScenarios: [
        'Debate: Should AI replace customer service?',
        'Defending a controversial strategic decision',
        'Courtroom opening statement'
      ],
      samplePrompt: 'Defend your position for 2 minutes against an opposing perspective.',
    ),
    const AIEvaluator(
      id: 'thesis_jury',
      name: 'Thesis Defense Jury',
      title: 'Academic & technical defense',
      description: 'Rigorous examination testing research methodology, evidence, and composure under questioning.',
      icon: '🎓',
      accentColor: Color(0xFF7C3AED),
      focusArea: 'Methodological rigor, precision & defense against academic cross-examination',
      specializedScenarios: [
        'Defending research methodology against jury challenge',
        'Explaining statistical significance and limitations',
        'Answering unexpected technical panel questions'
      ],
      samplePrompt: 'Present your research findings and justify why your methodology is valid.',
    ),
    const AIEvaluator(
      id: 'debate_opponent',
      name: 'The Debate Evaluator',
      title: 'Interactive AI Counter-Arguments',
      description: 'Simulates a live debate opponent offering real-time counter-arguments and objections.',
      icon: '⚔️',
      accentColor: Color(0xFFDC2626),
      focusArea: 'Spontaneous rebuttal, logical counter-arguments & staying calm under fire',
      specializedScenarios: [
        'Live Rebuttal: Universal Basic Income Debate',
        'Countering an opposing negotiator in business',
        'Refuting a logical fallacy in real-time'
      ],
      samplePrompt: 'Take a stance on remote work mandates and prepare to counter my objection.',
    ),
    const AIEvaluator(
      id: 'stage',
      name: 'The Stage',
      title: 'Public speaking & performance',
      description: 'Assesses high-stakes delivery, stage panic management, and audience presence.',
      icon: '🎤',
      accentColor: Color(0xFF8B5CF6),
      focusArea: 'Stage presence, projection & composure under pressure',
      specializedScenarios: [
        'Large Conference Keynote',
        'Handling unexpected slide failures gracefully',
        'Town Hall Speech with 200+ attendees'
      ],
      samplePrompt: 'Deliver a 3-minute speech imagining you are addressing a hall of 500 people.',
    ),
    const AIEvaluator(
      id: 'interview_evaluator',
      name: 'Interview Evaluator',
      title: 'Corporate & Tech Hiring Manager',
      description: 'Evaluates STAR method answers, behavioral responses, conciseness, and executive confidence.',
      icon: '👔',
      accentColor: Color(0xFF0284C7),
      focusArea: 'STAR method structured answers, behavioral Q&A & executive presence',
      specializedScenarios: [
        'Behavioral: "Tell me about a time you failed"',
        'System Design & Technical explanation for non-tech bosses',
        'Salary negotiation & executive leadership pitch'
      ],
      samplePrompt: 'Answer this classic interview prompt using the Situation, Task, Action, Result framework.',
    ),
  ];
}
