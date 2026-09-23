class SimulatedEnvironment {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final String recommendedEvaluatorId;
  final String visualDescription;
  final String ambientSoundName;
  final String pressureLevel;
  final List<String> evaluationCriteria;
  final String evaluatorLogicDescription;

  const SimulatedEnvironment({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.recommendedEvaluatorId,
    required this.visualDescription,
    required this.ambientSoundName,
    required this.pressureLevel,
    required this.evaluationCriteria,
    required this.evaluatorLogicDescription,
  });

  static const List<SimulatedEnvironment> environments = [
    SimulatedEnvironment(
      id: 'boardroom',
      title: 'Executive Boardroom',
      subtitle: 'Glass table, executive committee & presentation screen',
      emoji: '🏢',
      recommendedEvaluatorId: 'executive',
      visualDescription: 'High-rise glass office with 12 C-suite executives observing.',
      ambientSoundName: 'Low hum & subtle paper rustle',
      pressureLevel: 'High Executive Pressure',
      evaluationCriteria: [
        'Executive Presence & Conciseness',
        'Data Clarity & ROI Pitching',
        'Composure under C-Suite Objections',
      ],
      evaluatorLogicDescription:
          'Evaluates structural rigor, STAR method adherence, direct answers without fluff, and strategic confidence.',
    ),
    SimulatedEnvironment(
      id: 'thesis_hall',
      title: 'Grand University Defense Hall',
      subtitle: 'Academic lecture hall with professor jury bench',
      emoji: '🎓',
      recommendedEvaluatorId: 'thesis_jury',
      visualDescription: 'Tiered auditorium with 3 senior faculty jurors.',
      ambientSoundName: 'Echoing hall acoustics',
      pressureLevel: 'Academic Defense Examination',
      evaluationCriteria: [
        'Methodological Defense Rigor',
        'Evidence Precision & Terminology',
        'Cross-Examination Readiness',
      ],
      evaluatorLogicDescription:
          'Tests academic validity, empirical evidence justification, statistical clarity, and graceful handling of tough technical counter-questions.',
    ),
    SimulatedEnvironment(
      id: 'auditorium',
      title: 'TED-Style Stage & Auditorium',
      subtitle: 'Red circle stage, spotlighting & 500 audience members',
      emoji: '🎤',
      recommendedEvaluatorId: 'stage',
      visualDescription: 'Darkened auditorium with vibrant stage spotlight.',
      ambientSoundName: 'Murmur of large crowd & applause',
      pressureLevel: 'Stage Presence & Crowd Focus',
      evaluationCriteria: [
        'Narrative Hook & Emotional Impact',
        'Vocal Inflection & Tempo Control',
        'Stage Presence & Stage Panic Relief',
      ],
      evaluatorLogicDescription:
          'Measures audience connection, vocal dynamics, memorable storytelling hooks, and projection in front of large crowds.',
    ),
    SimulatedEnvironment(
      id: 'debate_arena',
      title: 'Parliamentary Debate Chamber',
      subtitle: 'Opposing benches, podium & parliamentary speaker',
      emoji: '🏛️',
      recommendedEvaluatorId: 'debate',
      visualDescription: 'Historic wood-panel debate chamber with opposing delegates.',
      ambientSoundName: 'Gavel taps & murmurs of assent',
      pressureLevel: 'Interactive Counter-Debate',
      evaluationCriteria: [
        'Spontaneous Rebuttal Speed',
        'Logical Coherence & Fallacy Avoidance',
        'Persuasive Argument Structuring',
      ],
      evaluatorLogicDescription:
          'Analyzes point-by-point rebuttal accuracy, countering fallacies in real-time, and maintaining persuasive authority during opposing interruptions.',
    ),
    SimulatedEnvironment(
      id: 'lounge',
      title: 'Casual Studio & Lounge',
      subtitle: 'Comfortable armchairs for relaxed everyday practice',
      emoji: '☕',
      recommendedEvaluatorId: 'coach',
      visualDescription: 'Warm, cozy podcast studio setting.',
      ambientSoundName: 'Soft ambient coffee house background',
      pressureLevel: 'Supportive & Building Habit',
      evaluationCriteria: [
        'Natural Speaking Ease & Warmth',
        'Daily Vocal Consistency',
        'Clarity & Conversational Flow',
      ],
      evaluatorLogicDescription:
          'Focuses on encouragement, vocal warming, reducing speech anxiety, and developing natural conversational flow.',
    ),
    SimulatedEnvironment(
      id: 'none',
      title: 'Clean Minimal Studio',
      subtitle: 'Distraction-free focus with pure audio visualizer',
      emoji: '⚡',
      recommendedEvaluatorId: 'all',
      visualDescription: 'Clean minimalist background for maximum concentration.',
      ambientSoundName: 'Silent focus studio',
      pressureLevel: 'Neutral Focus Mode',
      evaluationCriteria: [
        'Pure Pacing & Pitch Visualizer',
        'Filler Word Frequency',
        'Uninterrupted Speech Flow',
      ],
      evaluatorLogicDescription:
          'Distraction-free baseline evaluation focusing strictly on cadence, pitch modulation, and filler word elimination.',
    ),
  ];
}
