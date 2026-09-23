const briefService = require('../services/briefService');

class BriefController {
  async getAll(req, res, next) {
    try {
      const userId = req.user ? req.user.id : 'usr_amina';
      const briefs = await briefService.getBriefs(userId);
      return res.status(200).json({ success: true, count: briefs.length, data: briefs });
    } catch (err) {
      next(err);
    }
  }

  async markAsRead(req, res, next) {
    try {
      const userId = req.user ? req.user.id : 'usr_amina';
      const briefId = req.params.id;
      const briefs = await briefService.markAsRead(userId, briefId);
      return res.status(200).json({ success: true, data: briefs });
    } catch (err) {
      next(err);
    }
  }

  async triggerCron(req, res, next) {
    try {
      const cronService = require('../services/cronService');
      const newBrief = await cronService.generateAndSaveDailyBrief();
      return res.status(201).json({
        success: true,
        message: 'Daily Brief Cron Job executed successfully (05:00 AM trigger simulation)',
        data: newBrief
      });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new BriefController();
