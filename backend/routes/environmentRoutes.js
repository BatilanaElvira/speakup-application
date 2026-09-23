const express = require('express');
const router = express.Router();
const environmentController = require('../controllers/environmentController');

router.get('/', (req, res, next) => environmentController.getAll(req, res, next));
router.get('/:id', (req, res, next) => environmentController.getById(req, res, next));

module.exports = router;
