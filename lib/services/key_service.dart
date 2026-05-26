import 'package:shared_preferences/shared_preferences.dart';

class KeyService {
  static const _prefKey = 'openrouter_api_key';
  static String? _cachedKey;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedKey = prefs.getString(_prefKey);
  }

  static String? get currentKey => _cachedKey;
  static bool get hasKey => _cachedKey != null && _cachedKey!.trim().isNotEmpty;

  static Future<void> saveKey(String key) async {
    _cachedKey = key.trim(); // update in-memory immediately before async write
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, key.trim());
  }

  static Future<void> clearKey() async {
    _cachedKey = null; // update in-memory immediately before async write
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
