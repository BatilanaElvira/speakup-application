const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { authenticateToken, authorizeAdmin } = require('../middleware/authMiddleware');

// Metrics / Telemetry
router.get('/metrics', authenticateToken, authorizeAdmin, (req, res, next) => adminController.getMetrics(req, res, next));

// Users Management CRUD
router.get('/users', authenticateToken, authorizeAdmin, (req, res, next) => adminController.getUsers(req, res, next));
router.post('/users', authenticateToken, authorizeAdmin, (req, res, next) => adminController.createUser(req, res, next));
router.put('/users/:id', authenticateToken, authorizeAdmin, (req, res, next) => adminController.updateUser(req, res, next));
router.delete('/users/:id', authenticateToken, authorizeAdmin, (req, res, next) => adminController.deleteUser(req, res, next));

// Skill Rules Management CRUD
router.get('/skill-rules', authenticateToken, authorizeAdmin, (req, res, next) => adminController.getSkillRules(req, res, next));
router.post('/skill-rules', authenticateToken, authorizeAdmin, (req, res, next) => adminController.createSkillRule(req, res, next));
router.put('/skill-rules/:id', authenticateToken, authorizeAdmin, (req, res, next) => adminController.updateSkillRule(req, res, next));
router.delete('/skill-rules/:id', authenticateToken, authorizeAdmin, (req, res, next) => adminController.deleteSkillRule(req, res, next));

// Roadmap Management CRUD
router.get('/roadmap', authenticateToken, authorizeAdmin, (req, res, next) => adminController.getRoadmap(req, res, next));
router.post('/roadmap/stages', authenticateToken, authorizeAdmin, (req, res, next) => adminController.createRoadmapStage(req, res, next));
router.put('/roadmap/stages/:id', authenticateToken, authorizeAdmin, (req, res, next) => adminController.updateRoadmapStage(req, res, next));
router.delete('/roadmap/stages/:id', authenticateToken, authorizeAdmin, (req, res, next) => adminController.deleteRoadmapStage(req, res, next));

// Exercises Management CRUD
router.get('/exercises', authenticateToken, authorizeAdmin, (req, res, next) => adminController.getExercises(req, res, next));
router.post('/exercises', authenticateToken, authorizeAdmin, (req, res, next) => adminController.createExercise(req, res, next));
router.put('/exercises/:id', authenticateToken, authorizeAdmin, (req, res, next) => adminController.updateExercise(req, res, next));
router.delete('/exercises/:id', authenticateToken, authorizeAdmin, (req, res, next) => adminController.deleteExercise(req, res, next));

module.exports = router;
