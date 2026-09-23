const authService = require('../services/authService');

class AuthController {
  async register(req, res, next) {
    try {
      const { name, email, password, role } = req.body;
      if (!email) return res.status(400).json({ success: false, error: 'Email is required' });
      const result = await authService.register({ name, email, password, role });
      return res.status(201).json({ success: true, ...result });
    } catch (err) {
      next(err);
    }
  }

  async login(req, res, next) {
    try {
      const { email, password, role } = req.body;
      if (!email) return res.status(400).json({ success: false, error: 'Email is required' });
      const result = await authService.login({ email, password, role });
      return res.status(200).json({ success: true, ...result });
    } catch (err) {
      next(err);
    }
  }

  async socialLogin(req, res, next) {
    try {
      const { provider, email, name, avatarUrl } = req.body;
      const result = await authService.socialLogin({ provider, email, name, avatarUrl });
      return res.status(200).json({ success: true, ...result });
    } catch (err) {
      next(err);
    }
  }

  async forgotPassword(req, res, next) {
    try {
      const { email } = req.body;
      if (!email) return res.status(400).json({ success: false, error: 'Email is required' });
      const result = await authService.forgotPassword({ email });
      return res.status(200).json(result);
    } catch (err) {
      next(err);
    }
  }

  async verifyResetCode(req, res, next) {
    try {
      const { email, code } = req.body;
      if (!email || !code) return res.status(400).json({ success: false, error: 'Email and code are required' });
      const result = await authService.verifyResetCode({ email, code });
      return res.status(200).json(result);
    } catch (err) {
      next(err);
    }
  }

  async resetPassword(req, res, next) {
    try {
      const { email, code, newPassword } = req.body;
      if (!email || !code || !newPassword) {
        return res.status(400).json({ success: false, error: 'Email, code, and newPassword are required' });
      }
      const result = await authService.resetPassword({ email, code, newPassword });
      return res.status(200).json({ success: true, ...result });
    } catch (err) {
      next(err);
    }
  }

  async updateProfile(req, res, next) {
    try {
      const userId = req.user?.id || 'usr_amina';
      const result = await authService.updateProfile(userId, req.body);
      return res.status(200).json({ success: true, data: result });
    } catch (err) {
      next(err);
    }
  }

  async getMe(req, res, next) {
    try {
      return res.status(200).json({ success: true, user: req.user });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new AuthController();
