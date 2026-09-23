const sessionRepository = require('../repositories/sessionRepository');
const userRepository = require('../repositories/userRepository');

class PracticeSessionService {
  async getUserHistory(userId) {
    return await sessionRepository.getByUserId(userId);
  }

  async createAndAnalyzeSession(userId, payload) {
    const {
      mode = 'full',
      evaluatorId = 'coach',
      evaluatorName = 'The Coach',
      categoryId = 'tech',
      topic = 'General Practice Topic',
      durationSeconds = 45
    } = payload;

    // Simulate AI scoring engine calculation
    const rand = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;
    const overall = rand(78, 95);
    const clarity = rand(80, 96);
    const confidence = rand(75, 94);
    const pace = rand(78, 95);
    const fluency = rand(74, 94);
    const structure = rand(80, 96);
    const fillers = rand(0, 3);

    const sessionId = `sess_${Date.now()}`;

    const strengths = [
      'Strong vocal projection and clear baseline tone',
      'Logical thesis structure with defined key takeaways',
      'Consistent speaking rhythm matching the selected evaluator persona'
    ];

    const weaknesses = [
      fillers > 1 ? `Occasional filler words count (${fillers} detected during transitions)` : 'Minor pause before introducing secondary argument',
      'Vocal inflection can be elevated at concluding closing statement'
    ];

    const howToImprove = 'Take a deliberate 2-second breath before stating key evidence. Practice structuring your main points into three concise supporting pillars.';
    // Intelligently select recommended books targeted to the identified weakness
    let recommendedBooks = [];
    if (fillers > 1 || fluency < 80) {
      recommendedBooks = [
        {
          title: 'The Quick and Easy Way to Effective Speaking',
          author: 'Dale Carnegie',
          coverEmoji: '📔',
          targetProblem: 'Fluency & Filler Words',
          keyTakeaway: 'Eliminate filler words and develop poise and fluency through daily habit drills.',
          accentColorHex: '#42B883'
        },
        {
          title: 'Talk Like TED',
          author: 'Carmine Gallo',
          coverEmoji: '🎙️',
          targetProblem: 'Storytelling & Engagement',
          keyTakeaway: 'Master the 9 public speaking secrets of the world\'s top minds.',
          accentColorHex: '#3157D5'
        }
      ];
    } else if (confidence < 82 || confidence <= clarity) {
      recommendedBooks = [
        {
          title: 'Steal the Show',
          author: 'Michael Port',
          coverEmoji: '📘',
          targetProblem: 'Stage Fright & Performance Under Pressure',
          keyTakeaway: 'How to guarantee standing ovations and eliminate stage panic in high-stakes presentations.',
          accentColorHex: '#0284C7'
        },
        {
          title: 'Crucial Conversations',
          author: 'Kerry Patterson et al.',
          coverEmoji: '📗',
          targetProblem: 'Confidence & Pressure Management',
          keyTakeaway: 'Tools for talking when stakes are high, opinions vary, and emotions run strong.',
          accentColorHex: '#2BB7A9'
        }
      ];
    } else if (clarity < 84 || structure < 84) {
      recommendedBooks = [
        {
          title: 'Made to Stick',
          author: 'Chip Heath & Dan Heath',
          coverEmoji: '💡',
          targetProblem: 'Clarity & Argument Structure',
          keyTakeaway: 'Why some ideas survive and others die: use the SUCCES framework for unforgettable messaging.',
          accentColorHex: '#FF7A6B'
        },
        {
          title: 'TED Talks: The Official Guide',
          author: 'Chris Anderson',
          coverEmoji: '🎙️',
          targetProblem: 'Executive Structure & Delivery',
          keyTakeaway: 'How to explain complex ideas and build powerful talk frameworks.',
          accentColorHex: '#7C3AED'
        }
      ];
    } else {
      recommendedBooks = [
        {
          title: 'Talk Like TED',
          author: 'Carmine Gallo',
          coverEmoji: '🎙️',
          targetProblem: 'Storytelling & Rhetoric',
          keyTakeaway: 'Master the 9 public speaking secrets of the world\'s top minds.',
          accentColorHex: '#3157D5'
        },
        {
          title: 'Made to Stick',
          author: 'Chip Heath & Dan Heath',
          coverEmoji: '💡',
          targetProblem: 'Structure & Memorability',
          keyTakeaway: 'Craft ideas that stick in your audience\'s memory.',
          accentColorHex: '#FF7A6B'
        }
      ];
    }


    const audienceQuestions = [
      {
        question: `${evaluatorName} Challenge Question: How do you support your primary argument under high-pressure scenarios?`,
        speakerAnswer: 'I outline concrete data points, cite section context, and address stakeholder risks directly.'
      }
    ];

    const transcript = `Thank you for this opportunity. In my speech on "${topic}", I emphasized how vocal clarity, structured arguments, and deliberate pacing enable clear communication.`;

    const sessionData = {
      id: sessionId,
      user_id: userId,
      mode,
      evaluator_id: evaluatorId,
      evaluator_name: evaluatorName,
      category_id: categoryId,
      topic,
      duration_seconds: durationSeconds > 0 ? durationSeconds : 45,
      overall_score: overall,
      clarity_score: clarity,
      confidence_score: confidence,
      pace_score: pace,
      fluency_score: fluency,
      structure_score: structure,
      filler_word_count: fillers,
      transcript,
      strengths,
      weaknesses,
      how_to_improve: howToImprove,
      next_recommended_exercise: nextRecommendedExercise,
      recommended_books: recommendedBooks,
      audience_questions: audienceQuestions,
      is_saved_in_inbox: 1
    };

    const sessionResult = await sessionRepository.create(sessionData);

    // Award +50 XP and ensure user streak is maintained
    await userRepository.updateUserProgress(userId, { xpToAdd: 50 });

    return sessionResult;
  }
}

module.exports = new PracticeSessionService();
