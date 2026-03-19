import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage.dart';

class InstallChecker {
  static const _installedKey = 'is_installed';

  static Future<void> handleFirstInstall() async {
    final prefs = await SharedPreferences.getInstance();
    final isInstalled = prefs.getBool(_installedKey) ?? false;

    if (!isInstalled) {
      // 🔥 FIRST INSTALL (or reinstall)
      await SecureStorage.clearAll(); // 👈 clears iOS keychain
      await prefs.setBool(_installedKey, true);
    }
  }
}
