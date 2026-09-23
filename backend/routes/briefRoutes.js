const express = require('express');
const router = express.Router();
const briefController = require('../controllers/briefController');
const { authenticateToken } = require('../middleware/authMiddleware');

router.get('/', authenticateToken, (req, res, next) => briefController.getAll(req, res, next));
router.post('/trigger-cron', (req, res, next) => briefController.triggerCron(req, res, next));
router.post('/:id/read', authenticateToken, (req, res, next) => briefController.markAsRead(req, res, next));

module.exports = router;
