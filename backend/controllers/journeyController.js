const journeyService = require('../services/journeyService');

class JourneyController {
  async getTree(req, res, next) {
    try {
      const userId = req.user ? req.user.id : 'usr_amina';
      const tree = await journeyService.getJourneyTree(userId);
      return res.status(200).json({ success: true, data: tree });
    } catch (err) {
      next(err);
    }
  }

  async completeNode(req, res, next) {
    try {
      const userId = req.user ? req.user.id : 'usr_amina';
      const nodeId = req.params.id;
      const result = await journeyService.completeNode(userId, nodeId);
      return res.status(200).json({ success: true, data: result });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new JourneyController();
