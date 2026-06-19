import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  LocalStorage(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  String _k(String userId, String name) => 'user:$userId:$name';

  Future<void> saveJson(String userId, String key, Map<String, dynamic> value) {
    return _prefs.setString(_k(userId, key), jsonEncode(value));
  }

  Future<void> saveList(
    String userId,
    String key,
    List<Map<String, dynamic>> values,
  ) {
    return _prefs.setString(_k(userId, key), jsonEncode(values));
  }

  Map<String, dynamic>? getJson(String userId, String key) {
    final raw = _prefs.getString(_k(userId, key));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> getList(String userId, String key) {
    final raw = _prefs.getString(_k(userId, key));
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList();
    } catch (_) {
      return [];
    }
  }
}
