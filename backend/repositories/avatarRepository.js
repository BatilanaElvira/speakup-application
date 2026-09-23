const db = require('../config/db');

class AvatarRepository {
  async getAll() {
    const rows = await db.query('SELECT * FROM avatar_presets ORDER BY created_at ASC');
    if (rows && rows.length > 0) {
      return rows;
    }
    return db.memoryStore.avatar_presets || [];
  }

  async getById(id) {
    const rows = await db.query('SELECT * FROM avatar_presets WHERE id = ?', [id]);
    if (rows && rows.length > 0) {
      return rows[0];
    }
    const av = (db.memoryStore.avatar_presets || []).find(a => a.id === id);
    return av || null;
  }

  async create(avatar) {
    const { id = `av_${Date.now()}`, label, category = 'General', url } = avatar;
    await db.query(
      'INSERT INTO avatar_presets (id, label, category, url) VALUES (?, ?, ?, ?)',
      [id, label, category, url]
    );
    const newAv = { id, label, category, url, created_at: new Date() };
    if (!db.memoryStore.avatar_presets) db.memoryStore.avatar_presets = [];
    db.memoryStore.avatar_presets.push(newAv);
    return newAv;
  }
}

module.exports = new AvatarRepository();
