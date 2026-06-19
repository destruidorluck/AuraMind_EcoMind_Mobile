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

  Future<String?> migrateLegacyUserData({
    required String newUserId,
    required String email,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (newUserId.isEmpty || normalizedEmail.isEmpty) return null;

    final candidates = <({String userId, int populatedKeys})>[];
    for (final key in _prefs.getKeys()) {
      if (!key.startsWith('user:') || !key.endsWith(':accounts')) continue;
      final legacyUserId = key.substring(
        'user:'.length,
        key.length - ':accounts'.length,
      );
      if (legacyUserId.isEmpty || legacyUserId == newUserId) continue;

      final accounts = getList(legacyUserId, 'accounts');
      final ownsLegacyData = accounts.any(
        (account) =>
            (account['email'] ?? '').toString().trim().toLowerCase() ==
            normalizedEmail,
      );
      if (!ownsLegacyData) continue;

      final migrationKey = _k(newUserId, 'migrated-from:$legacyUserId');
      if (_prefs.getBool(migrationKey) == true) continue;
      final prefix = 'user:$legacyUserId:';
      final populatedKeys = _prefs
          .getKeys()
          .where((candidate) => candidate.startsWith(prefix))
          .map(_prefs.get)
          .where((value) => !_isEmptyStoredValue(value))
          .length;
      candidates.add((userId: legacyUserId, populatedKeys: populatedKeys));
    }
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => b.populatedKeys.compareTo(a.populatedKeys));
    final legacyUserId = candidates.first.userId;
    final prefix = 'user:$legacyUserId:';
    for (final legacyKey in _prefs.getKeys().where(
      (candidate) => candidate.startsWith(prefix),
    )) {
      final suffix = legacyKey.substring(prefix.length);
      final targetKey = _k(newUserId, suffix);
      final legacyValue = _prefs.get(legacyKey);
      final targetValue = _prefs.get(targetKey);
      if (legacyValue is String && targetValue is String) {
        final merged = _mergeJsonCollections(
          legacyValue: legacyValue,
          targetValue: targetValue,
        );
        if (merged != null) {
          if (merged != targetValue) {
            await _prefs.setString(targetKey, merged);
          }
          continue;
        }
      }
      if (targetValue != null &&
          !(_isEmptyStoredValue(targetValue) &&
              !_isEmptyStoredValue(legacyValue))) {
        continue;
      }
      if (legacyValue is String) {
        await _prefs.setString(targetKey, legacyValue);
      } else if (legacyValue is bool) {
        await _prefs.setBool(targetKey, legacyValue);
      } else if (legacyValue is int) {
        await _prefs.setInt(targetKey, legacyValue);
      } else if (legacyValue is double) {
        await _prefs.setDouble(targetKey, legacyValue);
      } else if (legacyValue is List<String>) {
        await _prefs.setStringList(targetKey, legacyValue);
      }
    }
    await _prefs.setBool(_k(newUserId, 'migrated-from:$legacyUserId'), true);
    return legacyUserId;
  }

  bool _isEmptyStoredValue(Object? value) {
    if (value == null) return true;
    if (value is String) {
      final clean = value.trim();
      if (clean.isEmpty) return true;
      try {
        final decoded = jsonDecode(clean);
        return decoded is List && decoded.isEmpty ||
            decoded is Map && decoded.isEmpty;
      } catch (_) {
        return false;
      }
    }
    if (value is List) return value.isEmpty;
    return false;
  }

  String? _mergeJsonCollections({
    required String legacyValue,
    required String targetValue,
  }) {
    try {
      final legacy = jsonDecode(legacyValue);
      final target = jsonDecode(targetValue);
      if (legacy is! List || target is! List) return null;
      final merged = <dynamic>[...target];
      final seen = merged.map(_collectionItemKey).toSet();
      for (final item in legacy) {
        if (seen.add(_collectionItemKey(item))) merged.add(item);
      }
      return jsonEncode(merged);
    } catch (_) {
      return null;
    }
  }

  String _collectionItemKey(dynamic item) {
    if (item is Map) {
      final id = (item['id'] ?? '').toString().trim();
      if (id.isNotEmpty) return 'id:$id';
    }
    return 'value:${jsonEncode(item)}';
  }
}
