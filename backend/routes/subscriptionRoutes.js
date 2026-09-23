const express = require('express');
const router = express.Router();
const subscriptionController = require('../controllers/subscriptionController');
const { authenticateToken } = require('../middleware/authMiddleware');

router.get('/plans', (req, res, next) => subscriptionController.getPlans(req, res, next));
router.post('/subscribe', authenticateToken, (req, res, next) => subscriptionController.subscribe(req, res, next));

module.exports = router;
