const avatarRepository = require('../repositories/avatarRepository');

class AvatarService {
  async getAvatars() {
    return await avatarRepository.getAll();
  }

  async getAvatarById(id) {
    const avatar = await avatarRepository.getById(id);
    if (!avatar) throw new Error('Avatar preset not found');
    return avatar;
  }

  async createAvatar(data) {
    if (!data.label || !data.url) {
      throw new Error('Avatar label and image URL are required');
    }
    return await avatarRepository.create(data);
  }
}

module.exports = new AvatarService();
