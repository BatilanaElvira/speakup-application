const db = require('../config/db');

class SkillRuleRepository {
  async getAll() {
    const rows = await db.query('SELECT * FROM skill_rules ORDER BY created_at ASC');
    if (rows && rows.length > 0) {
      return rows;
    }
    return db.memoryStore.skill_rules || [];
  }

  async getById(id) {
    const rows = await db.query('SELECT * FROM skill_rules WHERE id = ?', [id]);
    if (rows && rows.length > 0) {
      return rows[0];
    }
    return (db.memoryStore.skill_rules || []).find(r => r.id === id) || null;
  }

  async create(rule) {
    const {
      id = `rule_${Date.now()}`,
      title,
      focus_area,
      min_score_threshold = 80,
      max_filler_words = 2,
      guidance_tip
    } = rule;

    await db.query(
      'INSERT INTO skill_rules (id, title, focus_area, min_score_threshold, max_filler_words, guidance_tip) VALUES (?, ?, ?, ?, ?, ?)',
      [id, title, focus_area, min_score_threshold, max_filler_words, guidance_tip]
    );

    const newRule = {
      id,
      title,
      focus_area,
      min_score_threshold: Number(min_score_threshold),
      max_filler_words: Number(max_filler_words),
      guidance_tip,
      created_at: new Date()
    };

    if (!db.memoryStore.skill_rules) db.memoryStore.skill_rules = [];
    db.memoryStore.skill_rules.push(newRule);
    return newRule;
  }

  async update(id, ruleData) {
    const existing = await this.getById(id);
    if (!existing) return null;

    const title = ruleData.title !== undefined ? ruleData.title : existing.title;
    const focus_area = ruleData.focus_area !== undefined ? ruleData.focus_area : existing.focus_area;
    const min_score_threshold = ruleData.min_score_threshold !== undefined ? Number(ruleData.min_score_threshold) : existing.min_score_threshold;
    const max_filler_words = ruleData.max_filler_words !== undefined ? Number(ruleData.max_filler_words) : existing.max_filler_words;
    const guidance_tip = ruleData.guidance_tip !== undefined ? ruleData.guidance_tip : existing.guidance_tip;

    await db.query(
      'UPDATE skill_rules SET title = ?, focus_area = ?, min_score_threshold = ?, max_filler_words = ?, guidance_tip = ? WHERE id = ?',
      [title, focus_area, min_score_threshold, max_filler_words, guidance_tip, id]
    );

    const idx = (db.memoryStore.skill_rules || []).findIndex(r => r.id === id);
    if (idx !== -1) {
      db.memoryStore.skill_rules[idx] = {
        ...db.memoryStore.skill_rules[idx],
        title,
        focus_area,
        min_score_threshold,
        max_filler_words,
        guidance_tip,
        updated_at: new Date()
      };
    }

    return await this.getById(id);
  }

  async delete(id) {
    await db.query('DELETE FROM skill_rules WHERE id = ?', [id]);
    const idx = (db.memoryStore.skill_rules || []).findIndex(r => r.id === id);
    if (idx !== -1) {
      db.memoryStore.skill_rules.splice(idx, 1);
    }
    return true;
  }
}

module.exports = new SkillRuleRepository();
