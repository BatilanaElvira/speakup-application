class DailyKnowledgeBrief {
  final String id;
  final DateTime date;
  final String category;
  final String topic;
  final String emoji;
  final String summaryText;
  final List<String> keyFactBullets;
  final String suggestedSpeakingPrompt;
  final bool isRead;

  const DailyKnowledgeBrief({
    required this.id,
    required this.date,
    required this.category,
    required this.topic,
    required this.emoji,
    required this.summaryText,
    required this.keyFactBullets,
    required this.suggestedSpeakingPrompt,
    this.isRead = false,
  });

  static List<DailyKnowledgeBrief> mockArchive = [
    DailyKnowledgeBrief(
      id: 'brief_today',
      date: DateTime.now(),
      category: 'Technology & Physics',
      topic: 'Quantum Computing Fundamentals',
      emoji: '⚛️',
      summaryText:
          'Unlike classical computers that rely on bits (0s and 1s), quantum computers use qubits which can exist in superposition (0 and 1 simultaneously), unlocking exponential computing power for complex simulations.',
      keyFactBullets: [
        'Superposition allows processing vast combinations simultaneously.',
        'Quantum Entanglement links qubits instantly across distances.',
        'Primary applications: drug discovery, cryptography, and climate modeling.'
      ],
      suggestedSpeakingPrompt: 'Explain how quantum computing differs from traditional computers in 60 seconds.',
      isRead: false,
    ),
    DailyKnowledgeBrief(
      id: 'brief_yesterday',
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Behavioral Psychology',
      topic: 'The Loss Aversion Phenomenon',
      emoji: '🧠',
      summaryText:
          'Pioneered by psychologists Daniel Kahneman and Amos Tversky, loss aversion demonstrates that the psychological pain of losing something is twice as powerful as the pleasure of gaining it.',
      keyFactBullets: [
        'People prefer avoiding losses to acquiring equivalent gains.',
        'Explains why investors hold losing stocks too long.',
        'Widely used in persuasion, marketing, and policy design.'
      ],
      suggestedSpeakingPrompt: 'Give a 60-second example of loss aversion in everyday life.',
      isRead: true,
    ),
    DailyKnowledgeBrief(
      id: 'brief_day_before',
      date: DateTime.now().subtract(const Duration(days: 2)),
      category: 'Global Economics',
      topic: 'Inflation vs. Deflation Dynamics',
      emoji: '📈',
      summaryText:
          'Inflation is the rate at which purchasing power falls and prices rise, while deflation is a sustained decrease in general price levels. Central banks target a healthy 2% inflation rate for steady growth.',
      keyFactBullets: [
        'Hyperinflation destroys currency value rapidly.',
        'Deflation causes consumers to delay spending, hurting employment.',
        'Interest rates are central banks’ primary tool for control.'
      ],
      suggestedSpeakingPrompt: 'Summarize why central banks target 2% inflation in simple terms.',
      isRead: true,
    ),
  ];
}
