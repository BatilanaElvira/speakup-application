class LocalStorageImpl {
  static final Map<String, String> _memoryStore = {};

  static void setItem(String key, String value) {
    _memoryStore[key] = value;
  }

  static String? getItem(String key) {
    return _memoryStore[key];
  }

  static void removeItem(String key) {
    _memoryStore.remove(key);
  }
}
