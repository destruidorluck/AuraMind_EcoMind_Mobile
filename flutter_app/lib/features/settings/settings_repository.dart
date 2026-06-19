import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/storage/local_storage.dart' as app_storage;
import '../../services/aura_auth_service.dart';

class UserSettingsData {
  const UserSettingsData({
    required this.theme,
    required this.language,
    required this.ringtone,
    required this.onboardingCompleted,
    required this.selectedVoice,
    this.raw = const <String, dynamic>{},
  });

  final String theme;
  final String language;
  final String ringtone;
  final bool onboardingCompleted;
  final String selectedVoice;
  final Map<String, dynamic> raw;

  UserSettingsData copyWith({
    String? theme,
    String? language,
    String? ringtone,
    bool? onboardingCompleted,
    String? selectedVoice,
    Map<String, dynamic>? raw,
  }) {
    return UserSettingsData(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      ringtone: ringtone ?? this.ringtone,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      raw: raw ?? this.raw,
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'user_id': userId,
      'theme': theme,
      'app_language': language,
      'selected_alarm_sound': ringtone,
      'selected_voice': selectedVoice,
      'onboarding_completed': onboardingCompleted,
      'raw_payload': raw,
      'do_not_disturb': raw['do_not_disturb'] == true,
      'notification_delivery': raw['notification_delivery'] != false,
    };
  }

  static UserSettingsData fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> raw = const <String, dynamic>{};
    final rawPayload = json['raw_payload'];
    if (rawPayload is Map) {
      raw = rawPayload.cast<String, dynamic>();
    } else if (rawPayload is String && rawPayload.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawPayload);
        if (decoded is Map<String, dynamic>) raw = decoded;
      } catch (_) {
        raw = const <String, dynamic>{};
      }
    }

    return UserSettingsData(
      theme: (json['theme'] ?? 'dark').toString(),
      language: (json['app_language'] ?? 'pt').toString(),
      ringtone: (json['selected_alarm_sound'] ?? 'Radar').toString(),
      selectedVoice: (json['selected_voice'] ?? 'Aura').toString(),
      onboardingCompleted: json['onboarding_completed'] == true,
      raw: {
        ...raw,
        if (json.containsKey('do_not_disturb'))
          'do_not_disturb': json['do_not_disturb'] == true,
        if (json.containsKey('notification_delivery'))
          'notification_delivery': json['notification_delivery'] != false,
      },
    );
  }
}

class SettingsRepository {
  SettingsRepository(this._storage);

  final app_storage.LocalStorage _storage;

  SupabaseClient? get _client => AuraAuthService.client;

  static const String _localKey = 'user_settings';

  Future<UserSettingsData> load(String userId) async {
    final local = _storage.getJson(userId, _localKey);
    UserSettingsData localSettings = UserSettingsData.fromJson(local ?? {});

    final supabase = _client;
    if (supabase == null) return localSettings;

    try {
      final response = await supabase
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        await save(userId, localSettings);
        return localSettings;
      }

      final remoteSettings = UserSettingsData.fromJson(response);
      await _storage.saveJson(userId, _localKey, response);
      return remoteSettings;
    } catch (_) {
      return localSettings;
    }
  }

  Future<void> save(String userId, UserSettingsData data) async {
    final payload = data.toJson(userId);
    await _storage.saveJson(userId, _localKey, payload);
    final supabase = _client;
    if (supabase == null) return;
    try {
      await supabase.from('user_settings').upsert(payload);
    } catch (_) {
      // Keep local cache as source of truth when offline.
    }
  }
}
