const environmentRepository = require('../repositories/environmentRepository');

class EnvironmentService {
  async getEnvironments() {
    return await environmentRepository.getAll();
  }

  async getEnvironmentById(id) {
    const env = await environmentRepository.getById(id);
    if (!env) throw new Error('Environment not found');
    return env;
  }
}

module.exports = new EnvironmentService();
