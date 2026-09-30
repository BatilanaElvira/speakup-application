const express = require('express');
const router = express.Router();
const subscriptionController = require('../controllers/subscriptionController');
const { authenticateToken } = require('../middleware/authMiddleware');

router.get('/plans', (req, res, next) => subscriptionController.getPlans(req, res, next));
router.post('/subscribe', authenticateToken, (req, res, next) => subscriptionController.subscribe(req, res, next));
router.post('/process-payment', authenticateToken, (req, res, next) => subscriptionController.processDigiPayPayment(req, res, next));
router.get('/verify/:reference', (req, res, next) => subscriptionController.verifyPayment(req, res, next));

module.exports = router;
