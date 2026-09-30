import 'dart:convert';
import 'local_storage_stub.dart'
    if (dart.library.html) 'local_storage_web.dart';

class LocalStorageService {
  static const String _usersKey = 'speakup_local_registered_users_v2';
  static const String _activeSessionKey = 'speakup_active_user_session_v2';

  static void setString(String key, String value) {
    LocalStorageImpl.setItem(key, value);
  }

  static String? getString(String key) {
    return LocalStorageImpl.getItem(key);
  }

  static void remove(String key) {
    LocalStorageImpl.removeItem(key);
  }

  /// Load all cached users from persistent storage
  static Map<String, Map<String, dynamic>> loadUsers() {
    try {
      final raw = getString(_usersKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final Map<String, Map<String, dynamic>> result = {};
        decoded.forEach((email, data) {
          result[email.toLowerCase()] = Map<String, dynamic>.from(data);
        });
        return result;
      }
    } catch (_) {}
    return {};
  }

  /// Save all cached users into persistent storage
  static void saveUsers(Map<String, Map<String, dynamic>> users) {
    try {
      final jsonStr = jsonEncode(users);
      setString(_usersKey, jsonStr);
    } catch (_) {}
  }

  /// Save or update a single user in persistent storage
  static void upsertUser(String email, Map<String, dynamic> userData) {
    final users = loadUsers();
    users[email.toLowerCase()] = userData;
    saveUsers(users);
  }

  /// Load currently logged in user session (if any)
  static Map<String, dynamic>? loadActiveSession() {
    try {
      final raw = getString(_activeSessionKey);
      if (raw != null && raw.isNotEmpty) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Save active user session
  static void saveActiveSession(Map<String, dynamic> sessionData) {
    try {
      setString(_activeSessionKey, jsonEncode(sessionData));
    } catch (_) {}
  }

  /// Clear active user session on logout
  static void clearActiveSession() {
    remove(_activeSessionKey);
  }
}
