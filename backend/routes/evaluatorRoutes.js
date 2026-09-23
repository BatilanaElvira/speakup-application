const express = require('express');
const router = express.Router();
const evaluatorController = require('../controllers/evaluatorController');

router.get('/', (req, res, next) => evaluatorController.getAll(req, res, next));
router.get('/:id', (req, res, next) => evaluatorController.getById(req, res, next));

module.exports = router;
