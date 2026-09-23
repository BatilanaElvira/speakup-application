const avatarService = require('../services/avatarService');

class AvatarController {
  async getAll(req, res, next) {
    try {
      const avatars = await avatarService.getAvatars();
      return res.status(200).json({ success: true, count: avatars.length, data: avatars });
    } catch (err) {
      next(err);
    }
  }

  async getById(req, res, next) {
    try {
      const avatar = await avatarService.getAvatarById(req.params.id);
      return res.status(200).json({ success: true, data: avatar });
    } catch (err) {
      next(err);
    }
  }

  async create(req, res, next) {
    try {
      const avatar = await avatarService.createAvatar(req.body);
      return res.status(201).json({ success: true, data: avatar });
    } catch (err) {
      next(err);
    }
  }
}

module.exports = new AvatarController();
