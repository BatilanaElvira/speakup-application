const evaluatorService = require('../services/evaluatorService');

class EvaluatorController {
  async getAll(req, res, next) {
    try {
      const evaluators = await evaluatorService.getEvaluators();
      return res.status(200).json({ success: true, count: evaluators.length, data: evaluators });
    } catch (err) {
      next(err);
    }
  }

  async getById(req, res, next) {
    try {
      const evaluator = await evaluatorService.getEvaluatorById(req.params.id);
      return res.status(200).json({ success: true, data: evaluator });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new EvaluatorController();
