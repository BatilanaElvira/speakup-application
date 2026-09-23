const adminService = require('../services/adminService');

class AdminController {
  // --- USERS CRUD ---
  async getUsers(req, res, next) {
    try {
      const users = await adminService.getUsers();
      return res.status(200).json({ success: true, count: users.length, data: users });
    } catch (err) {
      next(err);
    }
  }

  async createUser(req, res, next) {
    try {
      const user = await adminService.createUser(req.body);
      return res.status(201).json({ success: true, data: user, message: 'User account created successfully' });
    } catch (err) {
      next(err);
    }
  }

  async updateUser(req, res, next) {
    try {
      const { id } = req.params;
      const user = await adminService.updateUser(id, req.body);
      if (!user) {
        return res.status(404).json({ success: false, error: 'User not found' });
      }
      return res.status(200).json({ success: true, data: user, message: 'User updated successfully' });
    } catch (err) {
      next(err);
    }
  }

  async deleteUser(req, res, next) {
    try {
      const { id } = req.params;
      await adminService.deleteUser(id);
      return res.status(200).json({ success: true, message: 'User deleted successfully' });
    } catch (err) {
      next(err);
    }
  }

  // --- SKILL RULES CRUD ---
  async getSkillRules(req, res, next) {
    try {
      const rules = await adminService.getSkillRules();
      return res.status(200).json({ success: true, count: rules.length, data: rules });
    } catch (err) {
      next(err);
    }
  }

  async createSkillRule(req, res, next) {
    try {
      const rule = await adminService.createSkillRule(req.body);
      return res.status(201).json({ success: true, data: rule, message: 'Skill rule created successfully' });
    } catch (err) {
      next(err);
    }
  }

  async updateSkillRule(req, res, next) {
    try {
      const { id } = req.params;
      const rule = await adminService.updateSkillRule(id, req.body);
      if (!rule) {
        return res.status(404).json({ success: false, error: 'Skill rule not found' });
      }
      return res.status(200).json({ success: true, data: rule, message: 'Skill rule updated successfully' });
    } catch (err) {
      next(err);
    }
  }

  async deleteSkillRule(req, res, next) {
    try {
      const { id } = req.params;
      await adminService.deleteSkillRule(id);
      return res.status(200).json({ success: true, message: 'Skill rule deleted successfully' });
    } catch (err) {
      next(err);
    }
  }

  // --- ROADMAP CRUD ---
  async getRoadmap(req, res, next) {
    try {
      const roadmap = await adminService.getRoadmap();
      return res.status(200).json({ success: true, count: roadmap.length, data: roadmap });
    } catch (err) {
      next(err);
    }
  }

  async createRoadmapStage(req, res, next) {
    try {
      const stage = await adminService.createRoadmapStage(req.body);
      return res.status(201).json({ success: true, data: stage, message: 'Roadmap stage created successfully' });
    } catch (err) {
      next(err);
    }
  }

  async updateRoadmapStage(req, res, next) {
    try {
      const { id } = req.params;
      const stage = await adminService.updateRoadmapStage(id, req.body);
      if (!stage) {
        return res.status(404).json({ success: false, error: 'Roadmap stage not found' });
      }
      return res.status(200).json({ success: true, data: stage, message: 'Roadmap stage updated successfully' });
    } catch (err) {
      next(err);
    }
  }

  async deleteRoadmapStage(req, res, next) {
    try {
      const { id } = req.params;
      await adminService.deleteRoadmapStage(id);
      return res.status(200).json({ success: true, message: 'Roadmap stage deleted successfully' });
    } catch (err) {
      next(err);
    }
  }

  // --- EXERCISES CRUD ---
  async getExercises(req, res, next) {
    try {
      const exercises = await adminService.getExercises();
      return res.status(200).json({ success: true, count: exercises.length, data: exercises });
    } catch (err) {
      next(err);
    }
  }

  async createExercise(req, res, next) {
    try {
      const exercise = await adminService.createExercise(req.body);
      return res.status(201).json({ success: true, data: exercise, message: 'Exercise created successfully' });
    } catch (err) {
      next(err);
    }
  }

  async updateExercise(req, res, next) {
    try {
      const { id } = req.params;
      const exercise = await adminService.updateExercise(id, req.body);
      if (!exercise) {
        return res.status(404).json({ success: false, error: 'Exercise not found' });
      }
      return res.status(200).json({ success: true, data: exercise, message: 'Exercise updated successfully' });
    } catch (err) {
      next(err);
    }
  }

  async deleteExercise(req, res, next) {
    try {
      const { id } = req.params;
      await adminService.deleteExercise(id);
      return res.status(200).json({ success: true, message: 'Exercise deleted successfully' });
    } catch (err) {
      next(err);
    }
  }

  // --- TELEMETRY / METRICS ---
  async getMetrics(req, res, next) {
    try {
      const metrics = await adminService.getPlatformMetrics();
      return res.status(200).json({ success: true, data: metrics });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new AdminController();
