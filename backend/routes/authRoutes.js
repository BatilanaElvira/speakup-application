const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authenticateToken } = require('../middleware/authMiddleware');

router.post('/register', (req, res, next) => authController.register(req, res, next));
router.post('/login', (req, res, next) => authController.login(req, res, next));
router.post('/social-login', (req, res, next) => authController.socialLogin(req, res, next));
router.post('/forgot-password', (req, res, next) => authController.forgotPassword(req, res, next));
router.post('/verify-reset-code', (req, res, next) => authController.verifyResetCode(req, res, next));
router.post('/reset-password', (req, res, next) => authController.resetPassword(req, res, next));
router.put('/profile', authenticateToken, (req, res, next) => authController.updateProfile(req, res, next));
router.get('/me', authenticateToken, (req, res, next) => authController.getMe(req, res, next));

module.exports = router;
