const express = require('express');
const router = express.Router();
const avatarController = require('../controllers/avatarController');

router.get('/', avatarController.getAll);
router.get('/:id', avatarController.getById);
router.post('/', avatarController.create);

module.exports = router;
