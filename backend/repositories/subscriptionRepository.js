const db = require('../config/db');

class SubscriptionRepository {
  async getAllPlans() {
    const rows = await db.query('SELECT * FROM subscription_plans');
    if (rows && rows.length > 0) {
      return rows.map(r => ({
        id: r.id,
        name: r.name,
        priceMonthly: parseFloat(r.price_monthly),
        priceYearly: parseFloat(r.price_yearly),
        isPopular: Boolean(r.is_popular),
        badge: r.badge,
        features: typeof r.features_json === 'string' ? JSON.parse(r.features_json) : r.features_json
      }));
    }
    return db.memoryStore.subscription_plans.map(p => ({
      id: p.id,
      name: p.name,
      priceMonthly: p.price_monthly,
      priceYearly: p.price_yearly,
      isPopular: Boolean(p.is_popular),
      badge: p.badge,
      features: typeof p.features_json === 'string' ? JSON.parse(p.features_json) : p.features_json
    }));
  }

  async getPlanById(id) {
    const plans = await this.getAllPlans();
    return plans.find(p => p.id === id) || null;
  }
}

module.exports = new SubscriptionRepository();
