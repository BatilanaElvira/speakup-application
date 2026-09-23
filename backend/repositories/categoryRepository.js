const db = require('../config/db');

class CategoryRepository {
  async getAll() {
    const rows = await db.query('SELECT * FROM categories');
    if (rows && rows.length > 0) {
      return rows.map(r => ({ ...r, sample_topics: JSON.parse(r.sample_topics_json || '[]') }));
    }
    return db.memoryStore.categories.map(c => ({
      ...c,
      sample_topics: JSON.parse(c.sample_topics_json || '[]')
    }));
  }

  async getById(id) {
    const rows = await db.query('SELECT * FROM categories WHERE id = ?', [id]);
    if (rows && rows.length > 0) {
      const c = rows[0];
      return { ...c, sample_topics: JSON.parse(c.sample_topics_json || '[]') };
    }
    const cat = db.memoryStore.categories.find(c => c.id === id);
    if (cat) return { ...cat, sample_topics: JSON.parse(cat.sample_topics_json || '[]') };
    return null;
  }

  async create(category) {
    const { id, title, emoji, card_color_hex, sample_topics = [] } = category;
    const sample_topics_json = JSON.stringify(sample_topics);
    await db.query(
      'INSERT INTO categories (id, title, emoji, card_color_hex, sample_topics_json) VALUES (?, ?, ?, ?, ?)',
      [id, title, emoji, card_color_hex, sample_topics_json]
    );
    const newCat = { id, title, emoji, card_color_hex, sample_topics_json, sample_topics };
    db.memoryStore.categories.push(newCat);
    return newCat;
  }

  async update(id, categoryData) {
    const cat = await this.getById(id);
    if (!cat) return null;
    const title = categoryData.title || cat.title;
    const emoji = categoryData.emoji || cat.emoji;
    const card_color_hex = categoryData.card_color_hex || cat.card_color_hex;
    const sample_topics = categoryData.sample_topics || cat.sample_topics;
    const sample_topics_json = JSON.stringify(sample_topics);

    await db.query(
      'UPDATE categories SET title = ?, emoji = ?, card_color_hex = ?, sample_topics_json = ? WHERE id = ?',
      [title, emoji, card_color_hex, sample_topics_json, id]
    );

    const memCat = db.memoryStore.categories.find(c => c.id === id);
    if (memCat) {
      memCat.title = title;
      memCat.emoji = emoji;
      memCat.card_color_hex = card_color_hex;
      memCat.sample_topics_json = sample_topics_json;
    }
    return { id, title, emoji, card_color_hex, sample_topics };
  }

  async delete(id) {
    await db.query('DELETE FROM categories WHERE id = ?', [id]);
    const idx = db.memoryStore.categories.findIndex(c => c.id === id);
    if (idx !== -1) db.memoryStore.categories.splice(idx, 1);
    return true;
  }
}

module.exports = new CategoryRepository();
