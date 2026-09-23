const briefRepository = require('../repositories/briefRepository');

class BriefService {
  async getBriefs(userId) {
    return await briefRepository.getAllBriefs(userId);
  }

  async markAsRead(userId, briefId) {
    await briefRepository.markBriefAsRead(userId, briefId);
    return await briefRepository.getAllBriefs(userId);
  }
}

module.exports = new BriefService();
