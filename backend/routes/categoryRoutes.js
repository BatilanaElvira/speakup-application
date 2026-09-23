const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/categoryController');
const { authenticateToken, authorizeAdmin } = require('../middleware/authMiddleware');

router.get('/', (req, res, next) => categoryController.getAll(req, res, next));
router.get('/:id', (req, res, next) => categoryController.getById(req, res, next));
router.post('/', authenticateToken, authorizeAdmin, (req, res, next) => categoryController.create(req, res, next));
router.put('/:id', authenticateToken, authorizeAdmin, (req, res, next) => categoryController.update(req, res, next));
router.delete('/:id', authenticateToken, authorizeAdmin, (req, res, next) => categoryController.delete(req, res, next));

module.exports = router;
