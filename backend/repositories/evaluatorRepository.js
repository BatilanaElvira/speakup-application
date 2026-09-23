const db = require('../config/db');

class EvaluatorRepository {
  async getAll() {
    const rows = await db.query('SELECT * FROM ai_evaluators');
    if (rows && rows.length > 0) {
      return rows.map(r => ({
        ...r,
        specialized_scenarios: JSON.parse(r.specialized_scenarios_json || '[]')
      }));
    }
    return db.memoryStore.ai_evaluators.map(e => ({
      ...e,
      specialized_scenarios: JSON.parse(e.specialized_scenarios_json || '[]')
    }));
  }

  async getById(id) {
    const rows = await db.query('SELECT * FROM ai_evaluators WHERE id = ?', [id]);
    if (rows && rows.length > 0) {
      const e = rows[0];
      return { ...e, specialized_scenarios: JSON.parse(e.specialized_scenarios_json || '[]') };
    }
    const ev = db.memoryStore.ai_evaluators.find(e => e.id === id);
    if (ev) return { ...ev, specialized_scenarios: JSON.parse(ev.specialized_scenarios_json || '[]') };
    return null;
  }
}

module.exports = new EvaluatorRepository();
