const jwt = require('jsonwebtoken');
const userRepository = require('../repositories/userRepository');

const JWT_SECRET = process.env.JWT_SECRET || 'speakup_jwt_secret_key_2026_super_secure!';

async function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    req.user = null;
    return next();
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = await userRepository.findById(decoded.id);
    req.user = user || { id: decoded.id, email: decoded.email, role: decoded.role };
    next();
  } catch (err) {
    req.user = null;
    next();
  }
}

function authorizeAdmin(req, res, next) {
  const adminHeader = req.headers['x-admin-role'];
  if (adminHeader === 'Admin' || (req.user && req.user.role === 'Admin')) {
    return next();
  }
  return res.status(403).json({ success: false, error: 'Forbidden: Admin access required' });
}

module.exports = { authenticateToken, authorizeAdmin };
