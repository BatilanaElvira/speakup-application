const db = require('../config/db');

class ExerciseRepository {
  async getAll() {
    const rows = await db.query('SELECT * FROM exercises ORDER BY created_at ASC');
    if (rows && rows.length > 0) {
      return rows;
    }
    return db.memoryStore.exercises || [];
  }

  async getById(id) {
    const rows = await db.query('SELECT * FROM exercises WHERE id = ?', [id]);
    if (rows && rows.length > 0) {
      return rows[0];
    }
    return (db.memoryStore.exercises || []).find(e => e.id === id) || null;
  }

  async create(exercise) {
    const {
      id = `ex_${Date.now()}`,
      title,
      category_id = 'tech',
      evaluator_name = 'The Coach',
      target_duration_seconds = 60,
      sample_prompt
    } = exercise;

    await db.query(
      'INSERT INTO exercises (id, title, category_id, evaluator_name, target_duration_seconds, sample_prompt) VALUES (?, ?, ?, ?, ?, ?)',
      [id, title, category_id, evaluator_name, target_duration_seconds, sample_prompt]
    );

    const newEx = {
      id,
      title,
      category_id,
      evaluator_name,
      target_duration_seconds: Number(target_duration_seconds),
      sample_prompt,
      created_at: new Date()
    };

    if (!db.memoryStore.exercises) db.memoryStore.exercises = [];
    db.memoryStore.exercises.push(newEx);
    return newEx;
  }

  async update(id, exerciseData) {
    const existing = await this.getById(id);
    if (!existing) return null;

    const title = exerciseData.title !== undefined ? exerciseData.title : existing.title;
    const category_id = exerciseData.category_id !== undefined ? exerciseData.category_id : existing.category_id;
    const evaluator_name = exerciseData.evaluator_name !== undefined ? exerciseData.evaluator_name : existing.evaluator_name;
    const target_duration_seconds = exerciseData.target_duration_seconds !== undefined ? Number(exerciseData.target_duration_seconds) : existing.target_duration_seconds;
    const sample_prompt = exerciseData.sample_prompt !== undefined ? exerciseData.sample_prompt : existing.sample_prompt;

    await db.query(
      'UPDATE exercises SET title = ?, category_id = ?, evaluator_name = ?, target_duration_seconds = ?, sample_prompt = ? WHERE id = ?',
      [title, category_id, evaluator_name, target_duration_seconds, sample_prompt, id]
    );

    const idx = (db.memoryStore.exercises || []).findIndex(e => e.id === id);
    if (idx !== -1) {
      db.memoryStore.exercises[idx] = {
        ...db.memoryStore.exercises[idx],
        title,
        category_id,
        evaluator_name,
        target_duration_seconds,
        sample_prompt,
        updated_at: new Date()
      };
    }

    return await this.getById(id);
  }

  async delete(id) {
    await db.query('DELETE FROM exercises WHERE id = ?', [id]);
    const idx = (db.memoryStore.exercises || []).findIndex(e => e.id === id);
    if (idx !== -1) {
      db.memoryStore.exercises.splice(idx, 1);
    }
    return true;
  }
}

module.exports = new ExerciseRepository();
