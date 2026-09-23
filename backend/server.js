require('dotenv').config();
const express = require('express');
const cors = require('cors');
const db = require('./config/db');
const routes = require('./routes');
const errorHandler = require('./middleware/errorHandler');
const cronService = require('./services/cronService');

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS for Flutter Web / Mobile & JSON parsing
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Register API Routes Presentation Tier
app.use('/api', routes);

// Global Error Handling Middleware
app.use(errorHandler);

// Initialize Database & Start Express Server
async function startServer() {
  await db.initDB();

  // Start 05:00 AM AI Daily Brief Cron Job
  cronService.initCronJobs();

  app.listen(PORT, () => {
    console.log(`=======================================================`);
    console.log(`🚀 SpeakUp Node.js + Express + MySQL Backend Server`);
    console.log(`📡 Listening on: http://localhost:${PORT}`);
    console.log(`⏰ Scheduled Cron: Daily Brief AI Generator @ 05:00 AM ('0 5 * * *')`);
    console.log(`🏗️  Logical Architecture: MVC (Model-View-Controller)`);
    console.log(`🏛️  Physical Architecture: N-Tier`);
    console.log(`=======================================================`);
  });
}

startServer();
