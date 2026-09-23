const db = require('../config/db');

class UserRepository {
  async findByEmail(email) {
    const rows = await db.query('SELECT * FROM users WHERE LOWER(email) = LOWER(?)', [email]);
    if (rows && rows.length > 0) return rows[0];
    return db.memoryStore.users.find(u => u.email.toLowerCase() === email.toLowerCase()) || null;
  }

  async findById(id) {
    const rows = await db.query('SELECT * FROM users WHERE id = ?', [id]);
    if (rows && rows.length > 0) return rows[0];
    return db.memoryStore.users.find(u => u.id === id) || null;
  }

  async create(user) {
    const {
      id = `usr_${Date.now()}`,
      name,
      email,
      password_hash = '$2a$10$7R9bZtQyD.GZl2M3v8X7e.X6E9R1T2W3Y4U5I6O7P8Q9R0S1T2U3V',
      role = 'Trainee',
      streak_days = 1,
      total_xp = 100,
      current_plan_id = 'pro',
      obstacle_id = 'confidence'
    } = user;
    const sql = 'INSERT INTO users (id, name, email, password_hash, role, streak_days, total_xp, current_plan_id, obstacle_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)';
    await db.query(sql, [id, name, email, password_hash, role, streak_days, total_xp, current_plan_id, obstacle_id]);

    const newUser = { id, name, email, password_hash, role, streak_days, total_xp, current_plan_id, obstacle_id, created_at: new Date() };
    db.memoryStore.users.push(newUser);
    return newUser;
  }

  async updateUserProgress(userId, { xpToAdd = 0, streakDays }) {
    const user = await this.findById(userId);
    if (!user) return null;

    const newXP = (user.total_xp || 0) + xpToAdd;
    const newStreak = streakDays !== undefined ? streakDays : (user.streak_days || 7);

    await db.query('UPDATE users SET total_xp = ?, streak_days = ? WHERE id = ?', [newXP, newStreak, userId]);
    user.total_xp = newXP;
    user.streak_days = newStreak;
    return user;
  }

  async updateUser(id, data) {
    const existing = await this.findById(id);
    if (!existing) return null;

    const name = data.name !== undefined ? data.name : existing.name;
    const email = data.email !== undefined ? data.email : existing.email;
    const role = data.role !== undefined ? data.role : existing.role;
    const streak_days = data.streak_days !== undefined ? Number(data.streak_days) : (existing.streak_days || 1);
    const total_xp = data.total_xp !== undefined ? Number(data.total_xp) : (existing.total_xp || 100);
    const current_plan_id = data.current_plan_id !== undefined ? data.current_plan_id : (existing.current_plan_id || 'pro');

    await db.query(
      'UPDATE users SET name = ?, email = ?, role = ?, streak_days = ?, total_xp = ?, current_plan_id = ? WHERE id = ?',
      [name, email, role, streak_days, total_xp, current_plan_id, id]
    );
    const idx = db.memoryStore.users.findIndex(u => u.id === id);
    if (idx !== -1) {
      db.memoryStore.users[idx] = { ...db.memoryStore.users[idx], name, email, role, streak_days, total_xp, current_plan_id };
    }
    return await this.findById(id);
  }

  async deleteUser(id) {
    await db.query('DELETE FROM users WHERE id = ?', [id]);
    const idx = db.memoryStore.users.findIndex(u => u.id === id);
    if (idx !== -1) {
      db.memoryStore.users.splice(idx, 1);
    }
    return true;
  }

  async getAllUsers() {
    const rows = await db.query('SELECT id, name, email, role, streak_days, total_xp, current_plan_id, created_at FROM users ORDER BY created_at DESC');
    if (rows && rows.length > 0) return rows;
    return db.memoryStore.users.map(({ password_hash, ...rest }) => rest);
  }
}

module.exports = new UserRepository();
