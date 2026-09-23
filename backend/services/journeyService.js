const journeyRepository = require('../repositories/journeyRepository');
const userRepository = require('../repositories/userRepository');

class JourneyService {
  async getJourneyTree(userId) {
    return await journeyRepository.getObstaclesWithStagesAndNodes(userId);
  }

  async completeNode(userId, nodeId) {
    const completedNodeIds = await journeyRepository.markNodeCompleted(userId, nodeId);
    // Award +75 XP for completing a journey node
    const updatedUser = await userRepository.updateUserProgress(userId, { xpToAdd: 75 });
    return {
      completedNodeIds,
      totalXP: updatedUser ? updatedUser.total_xp : 595,
      streakDays: updatedUser ? updatedUser.streak_days : 7
    };
  }
}

module.exports = new JourneyService();
