const categoryRepository = require('../repositories/categoryRepository');

class CategoryService {
  async getCategories() {
    return await categoryRepository.getAll();
  }

  async getCategoryById(id) {
    const cat = await categoryRepository.getById(id);
    if (!cat) throw new Error('Category not found');
    return cat;
  }

  async createCategory(data) {
    if (!data.id || !data.title) throw new Error('Category ID and Title are required');
    return await categoryRepository.create(data);
  }

  async updateCategory(id, data) {
    const updated = await categoryRepository.update(id, data);
    if (!updated) throw new Error('Category not found');
    return updated;
  }

  async deleteCategory(id) {
    return await categoryRepository.delete(id);
  }
}

module.exports = new CategoryService();
