const evaluatorRepository = require('../repositories/evaluatorRepository');

class EvaluatorService {
  async getEvaluators() {
    return await evaluatorRepository.getAll();
  }

  async getEvaluatorById(id) {
    const ev = await evaluatorRepository.getById(id);
    if (!ev) throw new Error('Evaluator not found');
    return ev;
  }
}

module.exports = new EvaluatorService();
