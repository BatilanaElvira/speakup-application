const express = require('express');
const router = express.Router();

const healthRoutes = require('./healthRoutes');
const authRoutes = require('./authRoutes');
const categoryRoutes = require('./categoryRoutes');
const evaluatorRoutes = require('./evaluatorRoutes');
const environmentRoutes = require('./environmentRoutes');
const sessionRoutes = require('./sessionRoutes');
const journeyRoutes = require('./journeyRoutes');
const briefRoutes = require('./briefRoutes');
const subscriptionRoutes = require('./subscriptionRoutes');
const adminRoutes = require('./adminRoutes');
const avatarRoutes = require('./avatarRoutes');

router.use('/health', healthRoutes);
router.use('/auth', authRoutes);
router.use('/categories', categoryRoutes);
router.use('/evaluators', evaluatorRoutes);
router.use('/environments', environmentRoutes);
router.use('/sessions', sessionRoutes);
router.use('/journey', journeyRoutes);
router.use('/daily-briefs', briefRoutes);
router.use('/briefs', briefRoutes);
router.use('/subscriptions', subscriptionRoutes);
router.use('/admin', adminRoutes);
router.use('/avatars', avatarRoutes);

module.exports = router;

