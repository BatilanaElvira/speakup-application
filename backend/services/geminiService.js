require('dotenv').config();
const { GoogleGenerativeAI } = require('@google/generative-ai');

function hasValidGeminiKey(apiKey) {
  if (!apiKey || typeof apiKey !== 'string') return false;
  const trimmed = apiKey.trim();
  // Support modern Google AI Studio AQ. keys and legacy AIza keys
  return (trimmed.startsWith('AIza') || trimmed.startsWith('AQ.')) && trimmed.length >= 25;
}

class GeminiService {
  constructor() {
    this.apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_API_KEY || '';
    this.modelName = process.env.GEMINI_MODEL || 'gemini-flash-lite-latest';
    this.fallbackModels = [
      'gemini-flash-lite-latest',
      'gemini-3.5-flash-lite',
      'gemini-3.5-flash',
      'gemini-flash-latest',
      'gemini-3.8-flash'
    ];
    this.client = null;
    this.model = null;

    this.initClient();
  }

  initClient() {
    if (hasValidGeminiKey(this.apiKey)) {
      try {
        this.client = new GoogleGenerativeAI(this.apiKey.trim());
        this.model = this.client.getGenerativeModel({ model: this.modelName });
        console.log(`🤖 [Gemini AI Service] Live Google Gemini AI initialized with model: ${this.modelName}.`);
      } catch (err) {
        console.warn('⚠️ [Gemini AI Service] Initialization notice:', err.message);
        this.client = null;
      }
    } else {
      this.client = null;
      if (this.apiKey && this.apiKey.trim().length > 0) {
        console.warn(`⚠️ [Gemini AI Service] Key in .env does not match Google Gemini API key format (Google AI Studio keys start with 'AIzaSy...'). Running in intelligent heuristic fallback mode. Get a free key at https://aistudio.google.com/apikey`);
      } else {
        console.log('ℹ️ [Gemini AI Service] Running in intelligent heuristic fallback mode. (Add your Gemini AI key in backend/.env: GEMINI_API_KEY=AIzaSy...)');
      }
    }
  }

  setApiKey(newKey) {
    this.apiKey = (newKey || '').trim();
    this.initClient();
    return this.isAvailable();
  }

  /**
   * Check if Gemini AI is initialized and ready for live requests
   */
  isAvailable() {
    return Boolean(this.client && hasValidGeminiKey(this.apiKey));
  }

  /**
   * Helper to execute prompt with primary model and automatic fallback on failure
   */
  async _generateContentWithFallback(prompt) {
    if (!this.isAvailable()) return null;

    // Ordered list of candidate models without duplicates
    const candidateModels = Array.from(new Set([this.modelName, ...this.fallbackModels]));
    let lastError = null;

    for (const modelToTry of candidateModels) {
      // Retry once if temporary 503 high demand spike occurs
      for (let attempt = 1; attempt <= 2; attempt++) {
        try {
          const modelInstance = this.client.getGenerativeModel({
            model: modelToTry,
            generationConfig: { responseMimeType: 'application/json' }
          });

          const result = await modelInstance.generateContent(prompt);
          let raw = result.response.text().trim();

          if (raw.startsWith('```json')) {
            raw = raw.replace(/^```json\s*/i, '').replace(/```\s*$/, '').trim();
          } else if (raw.startsWith('```')) {
            raw = raw.replace(/^```\s*/, '').replace(/```\s*$/, '').trim();
          }

          const parsed = JSON.parse(raw);
          parsed._aiModel = modelToTry;
          parsed._isAIGenerated = true;
          console.log(`✅ [Gemini AI Success] Evaluated speech with model: ${modelToTry}`);
          return parsed;
        } catch (err) {
          lastError = err;
          if (err.message && (err.message.includes('API_KEY_INVALID') || err.message.includes('API key not valid'))) {
            console.warn('⚠️ [Gemini AI] Invalid API key error from Google. Seamlessly falling back to heuristic evaluator.');
            return null;
          }
          const isHighDemand = err.message && (err.message.includes('503') || err.message.includes('high demand') || err.message.includes('429'));
          if (isHighDemand && attempt === 1) {
            console.warn(`⏳ [Gemini AI] Model ${modelToTry} busy. Retrying in 1s...`);
            await new Promise(r => setTimeout(r, 1000));
            continue;
          }
          console.warn(`⚠️ [Gemini AI] Model ${modelToTry} attempt notice: ${err.message}. Trying next candidate...`);
          break;
        }
      }
    }

    console.warn('⚠️ [Gemini AI Fallback]: All live Gemini model attempts exhausted:', lastError?.message);
    return null;
  }

  /**
   * Evaluates speech transcript / topic using Gemini AI
   */
  async evaluateSpeech({ topic, evaluatorName, evaluatorPersona, transcript, durationSeconds, documentContext, moduleType }) {
    if (!this.isAvailable()) {
      return null;
    }

    const isStageEvaluator = Boolean(
      (evaluatorName && (evaluatorName.toLowerCase().includes('stage') || evaluatorName.toLowerCase().includes('ted') || evaluatorName.toLowerCase().includes('keynote'))) ||
      (moduleType && (moduleType.toLowerCase().includes('stage') || moduleType.toLowerCase().includes('auditorium')))
    );

    const isDeliveryEvaluator = Boolean(
      evaluatorName && (
        evaluatorName.toLowerCase().includes('coach') ||
        evaluatorName.toLowerCase().includes('mentor') ||
        evaluatorName.toLowerCase().includes('vocal') ||
        evaluatorName.toLowerCase().includes('story') ||
        evaluatorName.toLowerCase().includes('presence') ||
        evaluatorName.toLowerCase().includes('toastmaster')
      )
    );

    let questionsInstruction = '';
    if (isStageEvaluator) {
      questionsInstruction = `This is a TED/Keynote Stage monologue. Do NOT generate evaluator follow-up questions during or after the talk. Set "audienceQuestions": [] and "isStageMonologue": true.`;
    } else if (isDeliveryEvaluator) {
      questionsInstruction = `As the evaluator "${evaluatorName || 'The Coach'}", your evaluation logic is primarily about HOW THE SPEAKER SAYS IT: vocal delivery, emotional state, voice trembling, nervousness, anxiety, fatigue, or sickness.
Listen carefully to the speech transcript and vocal tone:
Generate 2 empathetic, direct follow-up questions inquiring about their emotional composure, voice trembling, fear, or physical state (e.g. "Are you afraid or nervous? I noticed your voice trembling when speaking about [topic]", "Are you sick or fatigued today? Your projection softened in the middle", "Why did your voice tremble during your opening hook?").
Include them in "audienceQuestions" as an array of 2 objects:
[
  { "question": "Question about delivery, fear, voice trembling, or emotional state", "speakerAnswer": "Concise model answer" },
  { "question": "Second question probing pacing, nervousness, or energy level", "speakerAnswer": "Concise model answer" }
]`;
    } else {
      questionsInstruction = `As the evaluator "${evaluatorName || 'The Executive'}", your evaluation logic is primarily about WHAT THE SPEAKER SAID: logical validity, facts, data, arguments, and counterpoints.
Analyze the speech transcript carefully:
Generate 2 rigorous questions dissecting the specific claims, data, or arguments stated in the speech.
Include them in "audienceQuestions" as an array of 2 objects:
[
  { "question": "Question 1 directly referencing and challenging what was said in the speech", "speakerAnswer": "Concise model answer" },
  { "question": "Question 2 directly probing empirical evidence or logical counterarguments", "speakerAnswer": "Concise model answer" }
]`;
    }

    const prompt = `
You are an expert public speaking evaluator acting as the persona: "${evaluatorName || 'The Coach'}" (${evaluatorPersona || 'Balanced public speaking evaluator'}).
Topic: "${topic || 'General Practice'}"
Duration: ${durationSeconds || 45} seconds
Document Context: "${documentContext || 'None'}"
Speech Transcript: "${transcript || topic}"

${questionsInstruction}

Analyze the speech and return a JSON object with this EXACT structure:
{
  "overallScore": number (70-98),
  "clarityScore": number (70-98),
  "confidenceScore": number (70-98),
  "paceScore": number (70-98),
  "fluencyScore": number (70-98),
  "structureScore": number (70-98),
  "fillerWordCount": number (0-5),
  "strengths": [ "string", "string", "string" ],
  "weaknesses": [ "string", "string" ],
  "howToImprove": "string with specific actionable guidance",
  "nextRecommendedExercise": "string title of an exercise",
  "isStageMonologue": ${isStageEvaluator},
  "audienceQuestions": [
    ${isStageEvaluator ? '' : '{"question": "string", "speakerAnswer": "string"}, {"question": "string", "speakerAnswer": "string"}'}
  ],
  "audienceQuestion": {
    "question": "string primary question or stage note",
    "speakerAnswer": "string model answer"
  },
  "recommendedBooks": [
    {
      "title": "string book title",
      "author": "string author",
      "coverEmoji": "string emoji",
      "targetProblem": "string",
      "keyTakeaway": "string",
      "accentColorHex": "string hex color"
    },
    {
      "title": "string book title",
      "author": "string author",
      "coverEmoji": "string emoji",
      "targetProblem": "string",
      "keyTakeaway": "string",
      "accentColorHex": "string hex color"
    }
  ]
}
`;

    return await this._generateContentWithFallback(prompt);
  }

  /**
   * Generates a dynamic AI Daily Knowledge Brief
   */
  async generateDailyBrief(categoryTitle) {
    if (!this.isAvailable()) {
      return null;
    }

    const prompt = `
Generate a compelling 2-minute daily knowledge brief and speech challenge for speakers in the category: "${categoryTitle}".
Return a JSON object:
{
  "category": "${categoryTitle}",
  "topic": "string",
  "emoji": "string single emoji",
  "summary": "string 2-3 sentences",
  "keyFacts": ["fact 1", "fact 2", "fact 3"],
  "suggestedPrompt": "string speech exercise prompt"
}
`;

    return await this._generateContentWithFallback(prompt);
  }
}

module.exports = new GeminiService();

