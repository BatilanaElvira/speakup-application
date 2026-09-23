const subscriptionService = require('../services/subscriptionService');

class SubscriptionController {
  async getPlans(req, res, next) {
    try {
      const plans = await subscriptionService.getPlans();
      return res.status(200).json({ success: true, count: plans.length, data: plans });
    } catch (err) {
      next(err);
    }
  }

  async subscribe(req, res, next) {
    try {
      const userId = req.user ? req.user.id : 'usr_amina';
      const { planId } = req.body;
      const result = await subscriptionService.subscribeUser(userId, planId);
      return res.status(200).json({ success: true, ...result });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new SubscriptionController();
