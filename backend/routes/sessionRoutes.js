const express = require('express');
const router = express.Router();
const sessionController = require('../controllers/sessionController');
const { authenticateToken } = require('../middleware/authMiddleware');

router.get('/history', authenticateToken, (req, res, next) => sessionController.getHistory(req, res, next));
router.post('/analyze', authenticateToken, (req, res, next) => sessionController.createAndAnalyze(req, res, next));
router.put('/:id/qa', authenticateToken, (req, res, next) => sessionController.updateQAAnswers(req, res, next));
router.get('/gemini-status', (req, res, next) => sessionController.getGeminiStatus(req, res, next));
router.post('/test-gemini', (req, res, next) => sessionController.testGemini(req, res, next));
router.post('/gemini-key', (req, res, next) => sessionController.updateGeminiKey(req, res, next));

module.exports = router;

