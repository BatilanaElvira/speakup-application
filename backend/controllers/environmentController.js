const environmentService = require('../services/environmentService');

class EnvironmentController {
  async getAll(req, res, next) {
    try {
      const environments = await environmentService.getEnvironments();
      return res.status(200).json({ success: true, count: environments.length, data: environments });
    } catch (err) {
      next(err);
    }
  }

  async getById(req, res, next) {
    try {
      const env = await environmentService.getEnvironmentById(req.params.id);
      return res.status(200).json({ success: true, data: env });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new EnvironmentController();
