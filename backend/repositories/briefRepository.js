const db = require('../config/db');

class BriefRepository {
  async getAllBriefs(userId) {
    const readBriefIds = await this.getUserReadBriefIds(userId);
    const briefs = db.memoryStore.daily_briefs;

    return briefs.map(b => ({
      id: b.id,
      date: b.brief_date,
      category: b.category,
      topic: b.topic,
      emoji: b.emoji,
      summaryText: b.summary_text,
      keyFactBullets: typeof b.key_facts_json === 'string' ? JSON.parse(b.key_facts_json) : b.key_facts_json,
      suggestedSpeakingPrompt: b.suggested_prompt,
      isRead: readBriefIds.includes(b.id)
    }));
  }

  async getUserReadBriefIds(userId) {
    const rows = await db.query('SELECT brief_id FROM user_brief_reads WHERE user_id = ?', [userId]);
    if (rows && rows.length > 0) return rows.map(r => r.brief_id);
    return db.memoryStore.user_brief_reads.filter(r => r.user_id === userId).map(r => r.brief_id);
  }

  async markBriefAsRead(userId, briefId) {
    const existing = await db.query('SELECT * FROM user_brief_reads WHERE user_id = ? AND brief_id = ?', [userId, briefId]);
    if (!existing || existing.length === 0) {
      const id = `ubr_${Date.now()}`;
      await db.query('INSERT INTO user_brief_reads (id, user_id, brief_id) VALUES (?, ?, ?)', [id, userId, briefId]);
      if (!db.memoryStore.user_brief_reads.some(r => r.user_id === userId && r.brief_id === briefId)) {
        db.memoryStore.user_brief_reads.push({ id, user_id: userId, brief_id: briefId, read_at: new Date() });
      }
    }
    return true;
  }
}

module.exports = new BriefRepository();
