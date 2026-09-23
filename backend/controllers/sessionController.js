const practiceSessionService = require('../services/practiceSessionService');

class SessionController {
  async getHistory(req, res, next) {
    try {
      const userId = req.user ? req.user.id : 'usr_amina';
      const history = await practiceSessionService.getUserHistory(userId);
      return res.status(200).json({ success: true, count: history.length, data: history });
    } catch (err) {
      next(err);
    }
  }

  async createAndAnalyze(req, res, next) {
    try {
      const userId = req.user ? req.user.id : 'usr_amina';
      const result = await practiceSessionService.createAndAnalyzeSession(userId, req.body);
      return res.status(201).json({ success: true, data: result });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new SessionController();
