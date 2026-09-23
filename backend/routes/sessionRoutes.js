const express = require('express');
const router = express.Router();
const sessionController = require('../controllers/sessionController');
const { authenticateToken } = require('../middleware/authMiddleware');

router.get('/history', authenticateToken, (req, res, next) => sessionController.getHistory(req, res, next));
router.post('/analyze', authenticateToken, (req, res, next) => sessionController.createAndAnalyze(req, res, next));

module.exports = router;
