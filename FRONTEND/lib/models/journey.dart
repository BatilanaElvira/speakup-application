import 'package:flutter/material.dart';

class SpeakingObstacle {
  final String id;
  final String title;
  final String emoji;
  final String subtitle;
  final Color themeColor;
  final List<JourneyStage> stages;

  const SpeakingObstacle({
    required this.id,
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.themeColor,
    required this.stages,
  });
}

class JourneyStage {
  final int stageNumber;
  final String environmentName;
  final String environmentEmoji;
  final String title;
  final String description;
  final List<JourneyNode> nodes;

  const JourneyStage({
    required this.stageNumber,
    required this.environmentName,
    required this.environmentEmoji,
    required this.title,
    required this.description,
    required this.nodes,
  });
}

class JourneyNode {
  final String id;
  final String title;
  final String situationPrompt;
  final int durationSeconds;
  final String difficulty; // Easy, Medium, Hard
  final bool isCompleted;
  final int xpReward;

  const JourneyNode({
    required this.id,
    required this.title,
    required this.situationPrompt,
    required this.durationSeconds,
    required this.difficulty,
    this.isCompleted = false,
    required this.xpReward,
  });
}

class JourneyData {
  static List<SpeakingObstacle> obstacles = [
    SpeakingObstacle(
      id: 'confidence',
      title: 'Confidence',
      emoji: '😰',
      subtitle: "I'm afraid of speaking in front of people",
      themeColor: const Color(0xFFFF7A6B),
      stages: [
        JourneyStage(
          stageNumber: 1,
          environmentName: 'Your Room',
          environmentEmoji: '🌱',
          title: 'Find Your Voice',
          description: 'Safe solo space to speak out loud without judgment.',
          nodes: const [
            JourneyNode(
              id: 'conf_1_1',
              title: 'Introduce Yourself for 30 seconds',
              situationPrompt: 'Describe your name, what you do, and one secret passion you have in 30 seconds.',
              durationSeconds: 30,
              difficulty: 'Easy',
              isCompleted: true,
              xpReward: 50,
            ),
            JourneyNode(
              id: 'conf_1_2',
              title: 'Talk About Something You Love',
              situationPrompt: 'Pick a favorite hobby, movie, or food. Explain why you love it in 45 seconds.',
              durationSeconds: 45,
              difficulty: 'Easy',
              isCompleted: true,
              xpReward: 60,
            ),
            JourneyNode(
              id: 'conf_1_3',
              title: 'Express Your Pure Opinion',
              situationPrompt: 'State your honest opinion on whether working from home is better than office work.',
              durationSeconds: 60,
              difficulty: 'Easy',
              isCompleted: false,
              xpReward: 75,
            ),
          ],
        ),
        JourneyStage(
          stageNumber: 2,
          environmentName: 'Small Conversation',
          environmentEmoji: '☕',
          title: 'Speak Without Fear',
          description: 'Practice speaking in 1-on-1 informal settings.',
          nodes: const [
            JourneyNode(
              id: 'conf_2_1',
              title: 'Spontaneous Answer',
              situationPrompt: 'A colleague at coffee breaks asks: "What did you do over the weekend?" Answer spontaneously.',
              durationSeconds: 60,
              difficulty: 'Medium',
              isCompleted: false,
              xpReward: 90,
            ),
            JourneyNode(
              id: 'conf_2_2',
              title: 'Explain an Unfamiliar Topic',
              situationPrompt: 'Explain quantum physics or AI to a 10-year-old child in simple terms.',
              durationSeconds: 90,
              difficulty: 'Medium',
              isCompleted: false,
              xpReward: 100,
            ),
          ],
        ),
        JourneyStage(
          stageNumber: 3,
          environmentName: 'Meeting Room',
          environmentEmoji: '💼',
          title: 'Speak Under Pressure',
          description: 'Handle unexpected questions during a group meeting.',
          nodes: const [
            JourneyNode(
              id: 'conf_3_1',
              title: 'Manager Sudden Question',
              situationPrompt: 'Your manager asks: "What is your main priority this quarter?" Respond in 60 seconds.',
              durationSeconds: 60,
              difficulty: 'Hard',
              isCompleted: false,
              xpReward: 120,
            ),
            JourneyNode(
              id: 'conf_3_2',
              title: 'Debate an AI Objection',
              situationPrompt: 'Defend your project timeline when a team member objects it is too slow.',
              durationSeconds: 90,
              difficulty: 'Hard',
              isCompleted: false,
              xpReward: 150,
            ),
          ],
        ),
      ],
    ),
    SpeakingObstacle(
      id: 'clarity',
      title: 'Clarity',
      emoji: '🗣️',
      subtitle: "People don't always understand my ideas",
      themeColor: const Color(0xFF3157D5),
      stages: [
        JourneyStage(
          stageNumber: 1,
          environmentName: 'Your Desk',
          environmentEmoji: '📝',
          title: 'Simple Structures',
          description: 'Trim fluff and speak with razor-sharp clarity.',
          nodes: const [
            JourneyNode(
              id: 'clar_1_1',
              title: 'Explain an Object in 3 Sentences',
              situationPrompt: 'Describe how a smartphone works using only 3 simple sentences.',
              durationSeconds: 30,
              difficulty: 'Easy',
              isCompleted: true,
              xpReward: 50,
            ),
            JourneyNode(
              id: 'clar_1_2',
              title: 'Remove Filler Words Challenge',
              situationPrompt: 'Explain why water is essential without saying "um", "like", or "ah".',
              durationSeconds: 45,
              difficulty: 'Medium',
              isCompleted: false,
              xpReward: 80,
            ),
          ],
        ),
      ],
    ),
    SpeakingObstacle(
      id: 'pace',
      title: 'Speaking Pace',
      emoji: '⏱️',
      subtitle: 'I speak too fast or stumble when rushed',
      themeColor: const Color(0xFF2BB7A9),
      stages: [
        JourneyStage(
          stageNumber: 1,
          environmentName: 'Pacing Studio',
          environmentEmoji: '🎵',
          title: 'Mastering the Pause',
          description: 'Learn to use intentional pauses to command attention.',
          nodes: const [
            JourneyNode(
              id: 'pace_1_1',
              title: '3-Second Pause Technique',
              situationPrompt: 'Deliver a short proposal, inserting a distinct 3-second pause before key points.',
              durationSeconds: 60,
              difficulty: 'Medium',
              isCompleted: false,
              xpReward: 70,
            ),
          ],
        ),
      ],
    ),
    SpeakingObstacle(
      id: 'fluency',
      title: 'Fluency',
      emoji: '🤐',
      subtitle: 'I often hesitate or search for words',
      themeColor: const Color(0xFF42B883),
      stages: [
        JourneyStage(
          stageNumber: 1,
          environmentName: 'Fluency Gym',
          environmentEmoji: '⚡',
          title: 'Continuous Flow',
          description: 'Train your mind to speak without cognitive breaks.',
          nodes: const [
            JourneyNode(
              id: 'fl_1_1',
              title: 'Non-stop 60s Stream',
              situationPrompt: 'Speak continuously for 60 seconds about any technology topic.',
              durationSeconds: 60,
              difficulty: 'Medium',
              isCompleted: false,
              xpReward: 85,
            ),
          ],
        ),
      ],
    ),
    SpeakingObstacle(
      id: 'storytelling',
      title: 'Storytelling',
      emoji: '📖',
      subtitle: 'I struggle to make my speeches interesting',
      themeColor: const Color(0xFFF4B740),
      stages: [
        JourneyStage(
          stageNumber: 1,
          environmentName: 'Campfire',
          environmentEmoji: '🔥',
          title: 'Crafting the Hook',
          description: 'Hook your audience from the very first 10 seconds.',
          nodes: const [
            JourneyNode(
              id: 'st_1_1',
              title: 'The Unforgettable Hook',
              situationPrompt: 'Start a speech about resilience with a dramatic opening sentence.',
              durationSeconds: 45,
              difficulty: 'Medium',
              isCompleted: false,
              xpReward: 90,
            ),
          ],
        ),
      ],
    ),
    SpeakingObstacle(
      id: 'stage_fright',
      title: 'Stage Fright',
      emoji: '🎤',
      subtitle: 'I panic when everyone looks at me',
      themeColor: const Color(0xFFE56B6F),
      stages: [
        JourneyStage(
          stageNumber: 1,
          environmentName: 'Virtual Stage',
          environmentEmoji: '🏟️',
          title: 'Desensitization',
          description: 'Step-by-step exposure to high-pressure scenarios.',
          nodes: const [
            JourneyNode(
              id: 'sf_1_1',
              title: '30-Second Stage Spotlight',
              situationPrompt: 'Deliver a opening statement under spotlight pressure.',
              durationSeconds: 30,
              difficulty: 'Hard',
              isCompleted: false,
              xpReward: 100,
            ),
          ],
        ),
      ],
    ),
  ];
}
