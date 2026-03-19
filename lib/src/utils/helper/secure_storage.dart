import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'access_token';
  static const String _roleKey = 'role';

  /// ✅ Save token + role
  static Future<void> saveTokenAndRole({
    required String token,
    required String role,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
  }

  /// ✅ Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// ✅ Get role
  static Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  /// ✅ Clear everything (logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
