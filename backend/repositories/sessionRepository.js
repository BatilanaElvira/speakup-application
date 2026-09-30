const db = require('../config/db');

class SessionRepository {
  async getByUserId(userId) {
    const rows = await db.query('SELECT * FROM practice_sessions WHERE user_id = ? ORDER BY created_at DESC', [userId]);
    if (rows && rows.length > 0) {
      return rows.map(r => this._formatSession(r));
    }
    const filtered = db.memoryStore.practice_sessions.filter(s => s.user_id === userId);
    return filtered.map(s => this._formatSession(s));
  }

  async getById(id) {
    const rows = await db.query('SELECT * FROM practice_sessions WHERE id = ?', [id]);
    if (rows && rows.length > 0) return this._formatSession(rows[0]);
    const sess = db.memoryStore.practice_sessions.find(s => s.id === id);
    return sess ? this._formatSession(sess) : null;
  }

  async create(sessionData) {
    const {
      id,
      user_id,
      mode,
      evaluator_id,
      evaluator_name,
      category_id,
      topic,
      duration_seconds,
      overall_score,
      clarity_score,
      confidence_score,
      pace_score,
      fluency_score,
      structure_score,
      filler_word_count,
      transcript,
      strengths,
      weaknesses,
      how_to_improve,
      next_recommended_exercise,
      recommended_books = [],
      audience_questions = [],
      is_saved_in_inbox = 1
    } = sessionData;

    const strengths_json = JSON.stringify(strengths);
    const weaknesses_json = JSON.stringify(weaknesses);
    const recommended_books_json = JSON.stringify(recommended_books);
    const audience_questions_json = JSON.stringify(audience_questions);

    const sql = `
      INSERT INTO practice_sessions (
        id, user_id, mode, evaluator_id, evaluator_name, category_id, topic,
        duration_seconds, overall_score, clarity_score, confidence_score, pace_score,
        fluency_score, structure_score, filler_word_count, transcript, strengths_json,
        weaknesses_json, how_to_improve, next_recommended_exercise, recommended_books_json,
        audience_questions_json, is_saved_in_inbox
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    await db.query(sql, [
      id, user_id, mode, evaluator_id, evaluator_name, category_id, topic,
      duration_seconds, overall_score, clarity_score, confidence_score, pace_score,
      fluency_score, structure_score, filler_word_count, transcript, strengths_json,
      weaknesses_json, how_to_improve, next_recommended_exercise, recommended_books_json,
      audience_questions_json, is_saved_in_inbox ? 1 : 0
    ]);

    const newSession = {
      id,
      user_id,
      mode,
      evaluator_id,
      evaluator_name,
      category_id,
      topic,
      duration_seconds,
      overall_score,
      clarity_score,
      confidence_score,
      pace_score,
      fluency_score,
      structure_score,
      filler_word_count,
      transcript,
      strengths_json,
      weaknesses_json,
      how_to_improve,
      next_recommended_exercise,
      recommended_books_json,
      audience_questions_json,
      is_saved_in_inbox: is_saved_in_inbox ? 1 : 0,
      created_at: new Date()
    };

    db.memoryStore.practice_sessions.unshift(newSession);
    db.persistMemoryStore();
    return this._formatSession(newSession);
  }

  async updateQAAnswers(id, audienceQuestions) {
    const jsonStr = JSON.stringify(audienceQuestions);
    try {
      await db.query('UPDATE practice_sessions SET audience_questions_json = ? WHERE id = ?', [jsonStr, id]);
    } catch (_) {}
    const mem = db.memoryStore.practice_sessions.find(s => s.id === id);
    if (mem) {
      mem.audience_questions_json = jsonStr;
      db.persistMemoryStore();
      return this._formatSession(mem);
    }
    return null;
  }

  _formatSession(s) {
    return {
      id: s.id,
      user_id: s.user_id,
      mode: s.mode,
      evaluatorId: s.evaluator_id,
      evaluatorName: s.evaluator_name,
      categoryId: s.category_id,
      topic: s.topic,
      timestamp: s.created_at || s.timestamp || new Date(),
      durationSeconds: s.duration_seconds,
      overallScore: s.overall_score,
      clarityScore: s.clarity_score,
      confidenceScore: s.confidence_score,
      paceScore: s.pace_score,
      fluencyScore: s.fluency_score,
      structureScore: s.structure_score,
      fillerWordCount: s.filler_word_count,
      transcript: s.transcript,
      strengths: typeof s.strengths_json === 'string' ? JSON.parse(s.strengths_json) : (s.strengths || []),
      weaknesses: typeof s.weaknesses_json === 'string' ? JSON.parse(s.weaknesses_json) : (s.weaknesses || []),
      howToImprove: s.how_to_improve,
      nextRecommendedExercise: s.next_recommended_exercise,
      recommendedBooks: typeof s.recommended_books_json === 'string' ? JSON.parse(s.recommended_books_json) : (s.recommended_books || []),
      audienceQuestions: typeof s.audience_questions_json === 'string' ? JSON.parse(s.audience_questions_json) : (s.audience_questions || []),
      isSavedInInbox: Boolean(s.is_saved_in_inbox)
    };
  }
}

module.exports = new SessionRepository();
