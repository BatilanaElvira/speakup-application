const practiceSessionService = require('../services/practiceSessionService');
const geminiService = require('../services/geminiService');

class SessionController {
  async getHistory(req, res, next) {
    try {
      const userId = req.user ? req.user.id : (req.query.userId || req.headers['x-user-id']);
      if (!userId) {
        return res.status(200).json({ success: true, count: 0, data: [] });
      }
      const history = await practiceSessionService.getUserHistory(userId);
      return res.status(200).json({ success: true, count: history.length, data: history });
    } catch (err) {
      next(err);
    }
  }

  async createAndAnalyze(req, res, next) {
    try {
      const userId = req.user ? req.user.id : (req.body.userId || req.headers['x-user-id'] || 'usr_guest');
      const result = await practiceSessionService.createAndAnalyzeSession(userId, req.body);
      return res.status(201).json({ success: true, data: result });
    } catch (err) {
      next(err);
    }
  }

  async updateQAAnswers(req, res, next) {
    try {
      const { id } = req.params;
      const { audienceQuestions } = req.body;
      const result = await practiceSessionService.updateSessionQA(id, audienceQuestions);
      return res.status(200).json({ success: true, data: result });
    } catch (err) {
      next(err);
    }
  }

  async getGeminiStatus(req, res, next) {
    try {
      const isAvailable = geminiService.isAvailable();
      return res.status(200).json({
        success: true,
        available: isAvailable,
        primaryModel: geminiService.modelName,
        fallbackModels: geminiService.fallbackModels,
        message: isAvailable ? 'Google Gemini AI is configured and ready' : 'Gemini API key is not configured'
      });
    } catch (err) {
      next(err);
    }
  }

  async testGemini(req, res, next) {
    try {
      const { topic, transcript } = req.body;
      const evaluation = await geminiService.evaluateSpeech({
        topic: topic || 'The Future of AI and Human Communication',
        evaluatorName: 'The Coach',
        evaluatorPersona: 'Supportive mentor',
        transcript: transcript || 'I believe that AI empowers people to express themselves with higher confidence and clarity.',
        durationSeconds: 45
      });
      return res.status(200).json({
        success: true,
        isAIGenerated: Boolean(evaluation && evaluation._isAIGenerated),
        modelUsed: evaluation?._aiModel || 'fallback',
        data: evaluation
      });
    } catch (err) {
      next(err);
    }
  }

  async updateGeminiKey(req, res, next) {
    try {
      const { apiKey } = req.body;
      if (!apiKey) return res.status(400).json({ success: false, error: 'apiKey is required' });
      const available = geminiService.setApiKey(apiKey);
      return res.status(200).json({
        success: true,
        available,
        message: available ? 'Gemini API key updated and validated' : 'Key saved but does not match Google Gemini format (should start with AIzaSy...)'
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new SessionController();

