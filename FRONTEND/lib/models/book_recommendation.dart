class BookRecommendation {
  final String id;
  final String title;
  final String author;
  final String coverEmoji;
  final String targetProblem;
  final String keyTakeaway;
  final String amazonSearchUrl;

  const BookRecommendation({
    required this.id,
    required this.title,
    required this.author,
    required this.coverEmoji,
    required this.targetProblem,
    required this.keyTakeaway,
    required this.amazonSearchUrl,
  });

  static List<BookRecommendation> library = [
    const BookRecommendation(
      id: 'book_1',
      title: 'Talk Like TED',
      author: 'Carmine Gallo',
      coverEmoji: '📕',
      targetProblem: 'Storytelling & Engagement',
      keyTakeaway: 'The 9 public-speaking secrets of the world’s top minds: master emotional resonance, novelty, and memorable delivery.',
      amazonSearchUrl: 'https://www.google.com/search?q=Talk+Like+TED+Carmine+Gallo',
    ),
    const BookRecommendation(
      id: 'book_2',
      title: 'Crucial Conversations',
      author: 'Kerry Patterson et al.',
      coverEmoji: '📗',
      targetProblem: 'Confidence & Pressure',
      keyTakeaway: 'Tools for talking when stakes are high, opinions vary, and emotions run strong.',
      amazonSearchUrl: 'https://www.google.com/search?q=Crucial+Conversations+Kerry+Patterson',
    ),
    const BookRecommendation(
      id: 'book_3',
      title: 'Steal the Show',
      author: 'Michael Port',
      coverEmoji: '📘',
      targetProblem: 'Stage Fright & Performance',
      keyTakeaway: 'How to guarantee a standing ovation for all the performances in your life.',
      amazonSearchUrl: 'https://www.google.com/search?q=Steal+the+Show+Michael+Port',
    ),
    const BookRecommendation(
      id: 'book_4',
      title: 'Made to Stick',
      author: 'Chip Heath & Dan Heath',
      coverEmoji: '📙',
      targetProblem: 'Clarity & Structure',
      keyTakeaway: 'Why some ideas survive and others die: use the SUCCES framework (Simple, Unexpected, Concrete, Credible, Emotional, Story).',
      amazonSearchUrl: 'https://www.google.com/search?q=Made+to+Stick+Chip+Heath',
    ),
    const BookRecommendation(
      id: 'book_5',
      title: 'The Quick and Easy Way to Effective Speaking',
      author: 'Dale Carnegie',
      coverEmoji: '📔',
      targetProblem: 'Fluency & Filler Words',
      keyTakeaway: 'Develop poise, confidence, and fluency through practical daily habit drills.',
      amazonSearchUrl: 'https://www.google.com/search?q=Dale+Carnegie+Effective+Speaking',
    ),
    const BookRecommendation(
      id: 'book_6',
      title: 'TED Talks: The Official TED Guide to Public Speaking',
      author: 'Chris Anderson',
      coverEmoji: '🎙️',
      targetProblem: 'Executive Presence & Delivery',
      keyTakeaway: 'How to craft viral ideas and deliver talks that explain complex concepts with power.',
      amazonSearchUrl: 'https://www.google.com/search?q=TED+Talks+Chris+Anderson+Public+Speaking',
    ),
  ];

  /// Dynamically picks books tailored precisely to the user's identified speech weakness
  static List<BookRecommendation> getRecommendationsForWeakness({
    required int clarityScore,
    required int confidenceScore,
    required int paceScore,
    required int fluencyScore,
    required int structureScore,
    required int fillerWordCount,
    List<String>? weaknesses,
  }) {
    final weaknessText = (weaknesses ?? []).join(' ').toLowerCase();

    // 1. Check Filler Words & Fluency
    if (fillerWordCount > 1 || fluencyScore < 80 || weaknessText.contains('filler') || weaknessText.contains('fluency')) {
      return [
        library[4], // The Quick and Easy Way to Effective Speaking (Fluency & Filler Words)
        library[0], // Talk Like TED
      ];
    }

    // 2. Check Stage Fright & Confidence
    if (confidenceScore <= clarityScore && confidenceScore <= structureScore && confidenceScore < 82 || weaknessText.contains('fear') || weaknessText.contains('hesitat') || weaknessText.contains('confidence')) {
      return [
        library[2], // Steal the Show (Stage Fright & Performance)
        library[1], // Crucial Conversations (Confidence & Pressure)
      ];
    }

    // 3. Check Clarity & Structure
    if (clarityScore < 82 || structureScore < 82 || weaknessText.contains('structure') || weaknessText.contains('clarity')) {
      return [
        library[3], // Made to Stick (Clarity & Structure)
        library[5], // TED Talks Official Guide
      ];
    }

    // 4. Check Pace & Pauses
    if (paceScore < 82 || weaknessText.contains('pace') || weaknessText.contains('pause') || weaknessText.contains('rushed')) {
      return [
        library[1], // Crucial Conversations
        library[4], // Dale Carnegie
      ];
    }

    // 5. Default high-performer recommendation
    return [
      library[0], // Talk Like TED
      library[3], // Made to Stick
    ];
  }
}
