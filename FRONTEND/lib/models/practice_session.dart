import 'book_recommendation.dart';

enum PracticeMode { quick, full, goal }

class AudienceQuestion {
  final String question;
  final String speakerAnswer;

  const AudienceQuestion({
    required this.question,
    required this.speakerAnswer,
  });
}

class PracticeSessionResult {
  final String id;
  final PracticeMode mode;
  final String evaluatorId;
  final String evaluatorName;
  final String categoryId;
  final String topic;
  final DateTime timestamp;
  final int durationSeconds;
  final int overallScore;
  final int clarityScore;
  final int confidenceScore;
  final int paceScore;
  final int fluencyScore;
  final int structureScore;
  final int fillerWordCount;
  final String transcript;
  final List<String> strengths;
  final List<String> weaknesses;
  final String howToImprove;
  final String nextRecommendedExercise;
  final List<BookRecommendation> recommendedBooks;
  final List<AudienceQuestion> audienceQuestions;
  final bool isSavedInInbox;

  PracticeSessionResult({
    required this.id,
    required this.mode,
    required this.evaluatorId,
    required this.evaluatorName,
    required this.categoryId,
    required this.topic,
    required this.timestamp,
    required this.durationSeconds,
    required this.overallScore,
    required this.clarityScore,
    required this.confidenceScore,
    required this.paceScore,
    required this.fluencyScore,
    required this.structureScore,
    required this.fillerWordCount,
    required this.transcript,
    required this.strengths,
    required this.weaknesses,
    required this.howToImprove,
    required this.nextRecommendedExercise,
    this.recommendedBooks = const [],
    this.audienceQuestions = const [],
    this.isSavedInInbox = true,
  });

  static List<PracticeSessionResult> mockHistory = [
    PracticeSessionResult(
      id: 'sess_101',
      mode: PracticeMode.full,
      evaluatorId: 'thesis_jury',
      evaluatorName: 'Thesis Defense Jury',
      categoryId: 'tech',
      topic: 'Should artificial intelligence replace customer service workers?',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      durationSeconds: 112,
      overallScore: 82,
      clarityScore: 88,
      confidenceScore: 78,
      paceScore: 85,
      fluencyScore: 74,
      structureScore: 86,
      fillerWordCount: 3,
      transcript:
          'In my view, while artificial intelligence offers remarkable efficiency gains in routine inquiries, human customer service remains indispensable for high-empathy scenarios. Um, companies should aim for a hybrid model where AI handles basic triage while human agents handle complex concerns.',
      strengths: [
        'Clear logical structure with defined main point',
        'Strong executive vocabulary and tone',
        'Excellent articulation on technical terms'
      ],
      weaknesses: [
        'Slight hesitation when transitioning to the second point',
        'Pace sped up slightly near the 90-second mark'
      ],
      howToImprove:
          'Before speaking, take 5 seconds to mentally list your 2 supporting pillars. Insert a 2-second deliberate pause before transitioning to maintain calm authority.',
      nextRecommendedExercise: 'Defend your hybrid model recommendation against a budget objection.',
      recommendedBooks: [
        BookRecommendation.library[0], // Talk Like TED
        BookRecommendation.library[3], // Made to Stick
      ],
      audienceQuestions: const [
        AudienceQuestion(
          question: 'Jury Question: Why did you choose a hybrid model over full automation?',
          speakerAnswer:
              'A hybrid model mitigates operational risk. While automation handles 70% of low-complexity tickets, high-churn customer accounts require human empathy to prevent churn.',
        ),
      ],
    ),
    PracticeSessionResult(
      id: 'sess_102',
      mode: PracticeMode.quick,
      evaluatorId: 'coach',
      evaluatorName: 'The Coach',
      categoryId: 'personal_development',
      topic: 'Explain your favorite daily routine in 60 seconds.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      durationSeconds: 58,
      overallScore: 88,
      clarityScore: 90,
      confidenceScore: 86,
      paceScore: 89,
      fluencyScore: 85,
      structureScore: 90,
      fillerWordCount: 1,
      transcript:
          'Every morning I start with 10 minutes of silent meditation followed by a warm cup of green tea. This simple routine grounds my mind before notifications take over my day.',
      strengths: [
        'Warm and engaging tone',
        'Natural speech cadence with minimal filler words'
      ],
      weaknesses: [
        'Could project voice slightly more at the conclusion'
      ],
      howToImprove: 'Inhale deeply from your diaphragm before your closing sentence for maximum vocal power.',
      nextRecommendedExercise: 'Share a 60-second tip on time management.',
      recommendedBooks: [
        BookRecommendation.library[4], // Carnegie
      ],
    ),
  ];
}
