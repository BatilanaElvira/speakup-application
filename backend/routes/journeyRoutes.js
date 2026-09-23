const express = require('express');
const router = express.Router();
const journeyController = require('../controllers/journeyController');
const { authenticateToken } = require('../middleware/authMiddleware');

router.get('/tree', authenticateToken, (req, res, next) => journeyController.getTree(req, res, next));
router.post('/nodes/:id/complete', authenticateToken, (req, res, next) => journeyController.completeNode(req, res, next));

module.exports = router;
