enum NonAudioExerciseType { structureBuilder, fillerSubstitution, rhetoricQuiz }

class NonAudioExercise {
  final String id;
  final String title;
  final NonAudioExerciseType type;
  final String description;
  final String iconEmoji;
  final int xpReward;
  final String prompt;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const NonAudioExercise({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.iconEmoji,
    required this.xpReward,
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });

  static List<NonAudioExercise> exercises = [
    const NonAudioExercise(
      id: 'ex_str_1',
      title: 'Speech Structure Organizer',
      type: NonAudioExerciseType.structureBuilder,
      description: 'Arrange disorganized points into a logical Executive Pitch structure.',
      iconEmoji: '📝',
      xpReward: 60,
      prompt: 'Which opening statement creates the strongest executive narrative hook for a project proposal?',
      options: [
        'Today I want to read through our 40-page technical specification document line by line.',
        'We currently lose 14 hours per week to manual data triage; automating this process will save \$120,000 annually.',
        'Hello everyone, I am not really prepared today but I will try to talk about our system.',
        'Computers were invented in the 20th century and data processing has grown ever since.'
      ],
      correctOptionIndex: 1,
      explanation: 'Executive hooks start with a clear problem statement and quantifiable outcome (14 hours lost, \$120k saved).',
    ),
    const NonAudioExercise(
      id: 'ex_fil_1',
      title: 'Filler Word Eliminator Drill',
      type: NonAudioExerciseType.fillerSubstitution,
      description: 'Replace weak filler phrases with deliberate pauses & powerful transitions.',
      iconEmoji: '🗡️',
      xpReward: 50,
      prompt: 'Identify the best replacement for "Um, like, you know what I mean?" in a boardroom presentation.',
      options: [
        '[Insert 2-Second Deliberate Pause]',
        'Ah... basically...',
        'Sort of... kind of...',
        'Whatever...'
      ],
      correctOptionIndex: 0,
      explanation: 'Silence is your most powerful tool. A 2-second deliberate pause replaces filler hesitation with executive presence.',
    ),
    const NonAudioExercise(
      id: 'ex_rhe_1',
      title: 'Rhetorical Appeals Masterclass',
      type: NonAudioExerciseType.rhetoricQuiz,
      description: 'Identify Ethos (credibility), Pathos (emotion), and Logos (logic) in speeches.',
      iconEmoji: '🧠',
      xpReward: 70,
      prompt: '"As a chief medical officer with 20 years of clinical research, I have seen firsthand how preventive care saves lives." Which rhetorical appeal is being used?',
      options: [
        'Pathos (Emotional appeal)',
        'Logos (Statistical & logical proof)',
        'Ethos (Credibility & authority)',
        'Ad Hominem (Personal attack)'
      ],
      correctOptionIndex: 2,
      explanation: 'Ethos establishes authority and trust by citing 20 years of clinical research and professional credentials.',
    ),
  ];
}
