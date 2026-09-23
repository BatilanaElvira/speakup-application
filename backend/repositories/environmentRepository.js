const db = require('../config/db');

class EnvironmentRepository {
  async getAll() {
    const rows = await db.query('SELECT * FROM simulated_environments');
    if (rows && rows.length > 0) {
      return rows.map(r => ({
        ...r,
        strictness_options: JSON.parse(r.strictness_options_json || '[]')
      }));
    }
    return db.memoryStore.simulated_environments.map(env => ({
      ...env,
      strictness_options: JSON.parse(env.strictness_options_json || '[]')
    }));
  }

  async getById(id) {
    const rows = await db.query('SELECT * FROM simulated_environments WHERE id = ?', [id]);
    if (rows && rows.length > 0) {
      const env = rows[0];
      return { ...env, strictness_options: JSON.parse(env.strictness_options_json || '[]') };
    }
    const env = db.memoryStore.simulated_environments.find(e => e.id === id);
    if (env) return { ...env, strictness_options: JSON.parse(env.strictness_options_json || '[]') };
    return null;
  }
}

module.exports = new EnvironmentRepository();
