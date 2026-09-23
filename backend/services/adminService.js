const userRepository = require('../repositories/userRepository');
const skillRuleRepository = require('../repositories/skillRuleRepository');
const exerciseRepository = require('../repositories/exerciseRepository');
const journeyRepository = require('../repositories/journeyRepository');
const categoryRepository = require('../repositories/categoryRepository');
const evaluatorRepository = require('../repositories/evaluatorRepository');

class AdminService {
  // --- USERS MANAGEMENT ---
  async getUsers() {
    return await userRepository.getAllUsers();
  }

  async createUser(userData) {
    return await userRepository.create(userData);
  }

  async updateUser(id, userData) {
    return await userRepository.updateUser(id, userData);
  }

  async deleteUser(id) {
    return await userRepository.deleteUser(id);
  }

  // --- SKILL RULES MANAGEMENT ---
  async getSkillRules() {
    return await skillRuleRepository.getAll();
  }

  async createSkillRule(ruleData) {
    return await skillRuleRepository.create(ruleData);
  }

  async updateSkillRule(id, ruleData) {
    return await skillRuleRepository.update(id, ruleData);
  }

  async deleteSkillRule(id) {
    return await skillRuleRepository.delete(id);
  }

  // --- ROADMAP MANAGEMENT ---
  async getRoadmap() {
    return await journeyRepository.getAllRoadmap();
  }

  async createRoadmapStage(stageData) {
    return await journeyRepository.createStage(stageData);
  }

  async updateRoadmapStage(id, stageData) {
    return await journeyRepository.updateStage(id, stageData);
  }

  async deleteRoadmapStage(id) {
    return await journeyRepository.deleteStage(id);
  }

  // --- EXERCISES MANAGEMENT ---
  async getExercises() {
    return await exerciseRepository.getAll();
  }

  async createExercise(exerciseData) {
    return await exerciseRepository.create(exerciseData);
  }

  async updateExercise(id, exerciseData) {
    return await exerciseRepository.update(id, exerciseData);
  }

  async deleteExercise(id) {
    return await exerciseRepository.delete(id);
  }

  // --- PLATFORM METRICS & TELEMETRY ---
  async getPlatformMetrics() {
    const users = await userRepository.getAllUsers();
    const categories = await categoryRepository.getAll();
    const evaluators = await evaluatorRepository.getAll();
    const skillRules = await skillRuleRepository.getAll();
    const roadmap = await journeyRepository.getAllRoadmap();
    const exercises = await exerciseRepository.getAll();

    return {
      totalUsers: users.length,
      traineeCount: users.filter(u => u.role === 'Trainee').length,
      adminCount: users.filter(u => u.role === 'Admin').length,
      categoryCount: categories.length,
      evaluatorCount: evaluators.length,
      skillRuleCount: skillRules.length,
      roadmapStageCount: roadmap.length,
      exerciseCount: exercises.length,
      systemStatus: 'Healthy (MVC & N-Tier Active, Dark Admin Portal Live)'
    };
  }
}

module.exports = new AdminService();
