const express = require('express');
const router = express.Router();
const db = require('../config/db');

router.get('/', (req, res) => {
  return res.status(200).json({
    status: 'UP',
    service: 'SpeakUp Backend API Engine',
    architecture: 'MVC (Logical) & N-Tier (Physical)',
    databaseEngine: db.getIsFallback() ? 'In-Memory State Fallback' : 'MySQL Database',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;
