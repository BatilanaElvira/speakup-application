const subscriptionService = require('../services/subscriptionService');
const paymentService = require('../services/paymentService');

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
      const userRepository = require('../repositories/userRepository');
      let userId = req.user ? req.user.id : (req.body.userId || null);
      if (!userId && req.body.email) {
        const found = await userRepository.findByEmail(req.body.email);
        if (found) userId = found.id;
      }
      if (!userId) {
        return res.status(401).json({ success: false, error: 'User must be authenticated to subscribe' });
      }
      const { planId } = req.body;
      const result = await subscriptionService.subscribeUser(userId, planId);
      return res.status(200).json({ success: true, ...result });
    } catch (err) {
      next(err);
    }
  }

  async processDigiPayPayment(req, res, next) {
    try {
      const userRepository = require('../repositories/userRepository');
      let userId = req.user ? req.user.id : (req.body.userId || null);
      const email = req.body.email || (req.user ? req.user.email : null);

      if (!userId && email) {
        const existing = await userRepository.findByEmail(email);
        if (existing) userId = existing.id;
      }

      if (!userId) {
        return res.status(400).json({ success: false, error: 'User identification (userId or email) required for subscription payment' });
      }

      const { planId, amount, phoneNumber, operator, paymentMethod, cardDetails } = req.body;
      
      const result = await paymentService.processPayment({
        userId,
        planId: planId || 'pro',
        amount: amount || 3500,
        phoneNumber,
        operator: operator || 'MTN',
        email,
        paymentMethod: paymentMethod || 'MOBILE_MONEY',
        cardDetails
      });

      return res.status(200).json(result);
    } catch (err) {
      next(err);
    }
  }


  async verifyPayment(req, res, next) {
    try {
      const { reference } = req.params;
      const result = await paymentService.verifyPayment(reference);
      return res.status(200).json(result);
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new SubscriptionController();

