const subscriptionRepository = require('../repositories/subscriptionRepository');
const userRepository = require('../repositories/userRepository');

class SubscriptionService {
  async getPlans() {
    return await subscriptionRepository.getAllPlans();
  }

  async subscribeUser(userId, planId) {
    const plan = await subscriptionRepository.getPlanById(planId);
    if (!plan) throw new Error('Subscription plan not found');
    await userRepository.updateUser(userId, { current_plan_id: planId });
    return { plan, message: `Successfully subscribed to ${plan.name}` };
  }
}

module.exports = new SubscriptionService();

