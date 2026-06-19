import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuraStorageService {
  static SharedPreferences? _prefs;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  static SharedPreferences? get _safePrefs => _initialized ? _prefs : null;

  // User Preferences
  static Future<void> saveThemeMode(String mode) async {
    await _safePrefs?.setString('themeMode', mode);
  }

  static String? getThemeMode() => _safePrefs?.getString('themeMode');

  static Future<void> saveLanguage(String lang) async {
    await _safePrefs?.setString('language', lang);
  }

  static String? getLanguage() => _safePrefs?.getString('language');

  static Future<void> saveAppBrightness(double value) async {
    await _safePrefs?.setDouble('appBrightness', value);
  }

  static double? getAppBrightness() => _safePrefs?.getDouble('appBrightness');

  static Future<void> saveDeviceBrightness(double value) async {
    await _safePrefs?.setDouble('deviceBrightness', value);
  }

  static double? getDeviceBrightness() =>
      _safePrefs?.getDouble('deviceBrightness');

  static Future<void> saveAdaptiveBrightness(bool enabled) async {
    await _safePrefs?.setBool('adaptiveBrightness', enabled);
  }

  static bool? getAdaptiveBrightness() =>
      _safePrefs?.getBool('adaptiveBrightness');

  static Future<void> saveRingtone(String tone) async {
    await _safePrefs?.setString('ringtone', tone);
  }

  static String? getRingtone() => _safePrefs?.getString('ringtone');

  static Future<void> saveDoNotDisturb(bool enabled) async {
    await _safePrefs?.setBool('doNotDisturb', enabled);
  }

  static bool? getDoNotDisturb() => _safePrefs?.getBool('doNotDisturb');

  // Privacy & Notifications
  static Future<void> savePrivacySettings(Map<String, dynamic> settings) async {
    await _safePrefs?.setString('privacySettings', jsonEncode(settings));
  }

  static Map<String, dynamic>? getPrivacySettings() {
    final json = _safePrefs?.getString('privacySettings');
    return json != null ? jsonDecode(json) as Map<String, dynamic> : null;
  }

  static Future<void> saveNotificationSettings(
      Map<String, dynamic> settings) async {
    await _safePrefs?.setString('notificationSettings', jsonEncode(settings));
  }

  static Map<String, dynamic>? getNotificationSettings() {
    final json = _safePrefs?.getString('notificationSettings');
    return json != null ? jsonDecode(json) as Map<String, dynamic> : null;
  }

  // User Auth
  static Future<void> saveUserEmail(String email) async {
    await _safePrefs?.setString('userEmail', email);
  }

  static String? getUserEmail() => _safePrefs?.getString('userEmail');

  static Future<void> saveUserName(String name) async {
    await _safePrefs?.setString('userName', name);
  }

  static String? getUserName() => _safePrefs?.getString('userName');

  static Future<void> clearAuthData() async {
    await _safePrefs?.remove('userEmail');
    await _safePrefs?.remove('userName');
  }

  // App Settings
  static Future<void> saveLastLocation(String location) async {
    await _safePrefs?.setString('lastLocation', location);
  }

  static String? getLastLocation() => _safePrefs?.getString('lastLocation');

  static Future<void> saveLastWeatherTemp(int temp) async {
    await _safePrefs?.setInt('lastWeatherTemp', temp);
  }

  static int? getLastWeatherTemp() => _safePrefs?.getInt('lastWeatherTemp');

  // Clear all data (for logout)
  static Future<void> clearAll() async {
    await _safePrefs?.clear();
  }
}
