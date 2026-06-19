import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;

import '../../core/storage/local_storage.dart';
import '../../models/aura_models.dart';
import '../../services/aura_auth_service.dart';
import '../shared/model_codecs.dart';

class AuraAppDataBundle {
  AuraAppDataBundle({
    this.lists = const [],
    this.notes = const [],
    this.alarms = const [],
    this.timers = const [],
    this.reminders = const {},
    this.accounts = const [],
    this.activities = const [],
    this.notifications = const [],
    this.networks = const [],
    this.skillPermissions = const {},
    this.selectedWorldClockId,
    this.privacy,
  });

  final List<AuraList> lists;
  final List<AuraNote> notes;
  final List<AuraAlarm> alarms;
  final List<AuraTimerItem> timers;
  final Map<DateTime, List<AuraReminder>> reminders;
  final List<AuraAccount> accounts;
  final List<AuraActivity> activities;
  final List<AuraNotification> notifications;
  final List<AuraNetworkItem> networks;
  final Map<String, bool> skillPermissions;
  final String? selectedWorldClockId;
  final AuraPrivacy? privacy;
}

class AuraAppDataRepository {
  AuraAppDataRepository(this._storage);

  final LocalStorage _storage;

  SupabaseClient? get _client => AuraAuthService.client;

  Future<AuraAppDataBundle> load(String userId) async {
    return AuraAppDataBundle(
      lists: await _loadRows(
        userId,
        key: 'lists',
        table: 'lists',
        decoder: ModelCodecs.listFromJson,
      ),
      notes: await _loadRows(
        userId,
        key: 'notes',
        table: 'notes',
        decoder: ModelCodecs.noteFromJson,
      ),
      alarms: await _loadRows(
        userId,
        key: 'alarms',
        table: 'alarms',
        decoder: ModelCodecs.alarmFromJson,
      ),
      timers: await _loadRows(
        userId,
        key: 'timers',
        table: 'timers',
        decoder: ModelCodecs.timerFromJson,
      ),
      reminders: await _loadReminders(userId),
      accounts: await _loadAccounts(userId),
      activities: await _loadRows(
        userId,
        key: 'activities',
        table: 'activities',
        decoder: ModelCodecs.activityFromJson,
      ),
      notifications: await _loadRows(
        userId,
        key: 'notifications',
        table: 'app_notifications',
        decoder: ModelCodecs.notificationFromJson,
      ),
      networks: await _loadRows(
        userId,
        key: 'network_connections',
        table: 'device_connections',
        decoder: ModelCodecs.networkFromJson,
      ),
      skillPermissions: await _loadSkillPermissions(userId),
      selectedWorldClockId: await _loadSelectedWorldClock(userId),
      privacy: await _loadPrivacy(userId),
    );
  }

  Future<void> save(
    String userId, {
    required List<AuraList> lists,
    required List<AuraNote> notes,
    required List<AuraAlarm> alarms,
    required List<AuraTimerItem> timers,
    required Map<DateTime, List<AuraReminder>> reminders,
    required List<AuraAccount> accounts,
    required List<AuraActivity> activities,
    required List<AuraNotification> notifications,
    required List<AuraNetworkItem> networks,
    required List<AuraSkill> skills,
    required String selectedWorldClockId,
    AuraPrivacy? privacy,
  }) async {
    await Future.wait([
      _saveRows(
        userId,
        key: 'lists',
        table: 'lists',
        values: lists,
        encoder: ModelCodecs.listToJson,
        extra: (item, json) => {'title': item.title},
      ),
      _saveRows(
        userId,
        key: 'notes',
        table: 'notes',
        values: notes,
        encoder: ModelCodecs.noteToJson,
        extra: (item, json) => {
          'title': item.title,
          'body': item.preview,
        },
      ),
      _saveRows(
        userId,
        key: 'alarms',
        table: 'alarms',
        values: alarms,
        encoder: ModelCodecs.alarmToJson,
        extra: (item, json) => {
          'label': item.label,
          'time': item.time,
          'active': item.active,
          'tone': item.tone,
        },
      ),
      _saveRows(
        userId,
        key: 'timers',
        table: 'timers',
        values: timers,
        encoder: ModelCodecs.timerToJson,
        extra: (item, json) => {
          'label': item.label,
          'active': item.active,
          'remaining_seconds': item.remainingSeconds,
          'total_seconds': item.totalSeconds,
        },
      ),
      _saveReminders(userId, reminders),
      _saveAccounts(userId, accounts),
      _saveRows(
        userId,
        key: 'activities',
        table: 'activities',
        values: activities.take(100).toList(),
        encoder: ModelCodecs.activityToJson,
        extra: (item, json) => {
          'text': item.text,
          'origin': item.origin,
          'device': item.device,
        },
      ),
      _saveRows(
        userId,
        key: 'notifications',
        table: 'app_notifications',
        values: notifications.take(100).toList(),
        encoder: ModelCodecs.notificationToJson,
        extra: (item, json) => {
          'title': item.title,
          'body': item.body,
          'read': item.read,
        },
      ),
      _saveRows(
        userId,
        key: 'network_connections',
        table: 'device_connections',
        values: networks,
        encoder: ModelCodecs.networkToJson,
        extra: (item, json) => {
          'connection_type': item.type,
          'status': item.connected ? 'connected' : 'available',
          'network_name': item.name,
        },
      ),
      _saveSkillPermissions(userId, skills),
      _saveSelectedWorldClock(userId, selectedWorldClockId),
      if (privacy != null) _savePrivacy(userId, privacy),
    ]);
  }

  Future<void> createMemberInvite({
    required String userId,
    required String email,
    required String role,
    required String inviteUrl,
    Map<String, dynamic> payload = const {},
  }) async {
    final supabase = _client;
    if (supabase == null || email.trim().isEmpty) return;
    try {
      await supabase.from('member_invites').insert({
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'user_id': userId,
        'email': email.trim().toLowerCase(),
        'role': role,
        'invite_url': inviteUrl,
        'status': 'pending',
        'payload': payload,
      });
    } catch (_) {}
  }

  Future<List<T>> _loadRows<T>(
    String userId, {
    required String key,
    required String table,
    required T Function(Map<String, dynamic>) decoder,
  }) async {
    final local = _storage.getList(userId, key).map(decoder).toList();
    final supabase = _client;
    if (supabase == null) return local;

    try {
      final response = await supabase
          .from(table)
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);
      final rows = response
          .whereType<Map>()
          .map((row) => row.cast<String, dynamic>())
          .map((row) {
            final payload = row['payload'];
            if (payload is Map) {
              return payload.cast<String, dynamic>();
            }
            return row;
          })
          .map(decoder)
          .toList();
      if (rows.isEmpty && local.isNotEmpty) return local;
      await _storage.saveList(
        userId,
        key,
        rows.map((item) => _encodeDynamic(item)).toList(),
      );
      return rows;
    } catch (_) {
      return local;
    }
  }

  Future<List<AuraAccount>> _loadAccounts(String userId) async {
    final local = _storage
        .getList(userId, 'accounts')
        .map(ModelCodecs.accountFromJson)
        .toList();
    final supabase = _client;
    if (supabase == null) return local;

    try {
      final response = await supabase
          .from('group_members')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);
      final rows = response
          .whereType<Map>()
          .map((row) => row.cast<String, dynamic>())
          .where((row) => (row['group_id'] ?? '').toString().isEmpty)
          .map((row) {
            final payload = row['payload'];
            if (payload is Map) {
              return {
                ...row,
                ...payload.cast<String, dynamic>(),
              };
            }
            return row;
          })
          .map(ModelCodecs.accountFromJson)
          .toList();
      for (final account in rows) {
        final imagePath = account.imagePath?.trim() ?? '';
        if (imagePath.isEmpty) continue;
        try {
          account.imageAsset = await supabase.storage
              .from('aura-profile-photos')
              .createSignedUrl(imagePath, 60 * 60 * 24 * 7);
        } catch (_) {}
      }
      rows.sort((a, b) {
        if (a.id == userId) return -1;
        if (b.id == userId) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      if (rows.isEmpty && local.isNotEmpty) return local;
      await _storage.saveList(
        userId,
        'accounts',
        rows.map(ModelCodecs.accountToJson).toList(),
      );
      return rows;
    } catch (_) {
      return local;
    }
  }

  Future<void> _saveAccounts(String userId, List<AuraAccount> accounts) async {
    final payload = accounts.map(ModelCodecs.accountToJson).toList();
    await _storage.saveList(userId, 'accounts', payload);
    final supabase = _client;
    if (supabase == null) return;

    try {
      if (accounts.isEmpty) return;
      await supabase.from('group_members').upsert(
            accounts.map((account) {
              final json = ModelCodecs.accountToJson(account);
              return {
                'id': account.id,
                'user_id': userId,
                'name': account.name,
                'email': account.email,
                'role': account.role,
                'can_manage_devices': account.canManageDevices,
                'can_manage_members': account.canManageMembers,
                'can_use_voice': account.canUseVoice,
                'can_use_media': account.canUseMedia,
                'can_view_history': account.canViewHistory,
                if (account.imageAsset?.trim().isNotEmpty == true)
                  'avatar_url': account.imageAsset,
                if (account.imagePath?.trim().isNotEmpty == true)
                  'avatar_path': account.imagePath,
                'payload': json,
                'updated_at': DateTime.now().toIso8601String(),
              };
            }).toList(),
          );
    } catch (_) {}
  }

  Future<void> deleteAccount(String userId, String accountId) async {
    final accounts = _storage
        .getList(userId, 'accounts')
        .where((row) => (row['id'] ?? '').toString() != accountId)
        .toList();
    await _storage.saveList(userId, 'accounts', accounts);
    final supabase = _client;
    if (supabase == null || userId.isEmpty || accountId.isEmpty) return;
    try {
      await supabase
          .from('group_members')
          .delete()
          .eq('user_id', userId)
          .eq('id', accountId);
    } catch (_) {}
  }

  Future<void> _saveRows<T>(
    String userId, {
    required String key,
    required String table,
    required List<T> values,
    required Map<String, dynamic> Function(T) encoder,
    Map<String, dynamic> Function(T, Map<String, dynamic>)? extra,
  }) async {
    final payload = values.map(encoder).toList();
    await _storage.saveList(userId, key, payload);
    final supabase = _client;
    if (supabase == null) return;

    try {
      if (payload.isEmpty) return;
      await supabase.from(table).upsert(
            values.map((item) {
              final json = encoder(item);
              final row = {
                'id': json['id']?.toString().isNotEmpty == true
                    ? json['id'].toString()
                    : DateTime.now().microsecondsSinceEpoch.toString(),
                'user_id': userId,
                'payload': json,
                'updated_at': DateTime.now().toIso8601String(),
                if (extra != null) ...extra(item, json),
              };
              return row;
            }).toList(),
          );
    } catch (_) {
      // The local cache remains the immediate source when Supabase is offline
      // or while the SQL migration has not been applied yet.
    }
  }

  Future<Map<DateTime, List<AuraReminder>>> _loadReminders(String userId) async {
    final localRows = _storage.getList(userId, 'reminders');
    final local = _remindersFromRows(localRows);
    final supabase = _client;
    if (supabase == null) return local;

    try {
      final response = await supabase
          .from('reminders')
          .select()
          .eq('user_id', userId)
          .order('reminder_date', ascending: true);
      final rows = response.whereType<Map>().map((row) {
        final cast = row.cast<String, dynamic>();
        final payload = cast['payload'];
        return {
          ...cast,
          if (payload is Map) ...payload.cast<String, dynamic>(),
        };
      }).toList();
      if (rows.isEmpty && local.isNotEmpty) return local;
      await _storage.saveList(userId, 'reminders', rows);
      return _remindersFromRows(rows);
    } catch (_) {
      return local;
    }
  }

  Future<void> _saveReminders(
    String userId,
    Map<DateTime, List<AuraReminder>> reminders,
  ) async {
    final rows = <Map<String, dynamic>>[];
    for (final entry in reminders.entries) {
      final date = _dateOnly(entry.key);
      for (final reminder in entry.value) {
        final json = ModelCodecs.reminderToJson(reminder);
        rows.add({
          ...json,
          'reminder_date': date.toIso8601String().split('T').first,
        });
      }
    }
    await _storage.saveList(userId, 'reminders', rows);
    final supabase = _client;
    if (supabase == null) return;

    try {
      if (rows.isEmpty) return;
      await supabase.from('reminders').upsert(
            rows
                .map(
                  (row) => {
                    'id': row['id'],
                    'user_id': userId,
                    'text': row['text'],
                    'time': row['time'],
                    'end_time': row['end_time'],
                    'repeat': row['repeat'],
                    'alert_minutes_before': row['alert_minutes_before'],
                    'active': row['active'],
                    'reminder_date': row['reminder_date'],
                    'payload': row,
                    'updated_at': DateTime.now().toIso8601String(),
                  },
                )
                .toList(),
          );
    } catch (_) {}
  }

  Map<DateTime, List<AuraReminder>> _remindersFromRows(
    List<Map<String, dynamic>> rows,
  ) {
    final result = <DateTime, List<AuraReminder>>{};
    for (final row in rows) {
      final date =
          DateTime.tryParse((row['reminder_date'] ?? '').toString()) ??
          DateTime.now();
      final key = _dateOnly(date);
      result.putIfAbsent(key, () => []).add(ModelCodecs.reminderFromJson(row));
    }
    return result;
  }

  Future<Map<String, bool>> _loadSkillPermissions(String userId) async {
    final local = _storage.getJson(userId, 'skill_permissions') ?? {};
    final supabase = _client;
    if (supabase == null) {
      return local.map((key, value) => MapEntry(key, value == true));
    }

    try {
      final response = await supabase
          .from('skills')
          .select('skill_id, connected')
          .eq('user_id', userId);
      final permissions = <String, bool>{};
      for (final row in response.whereType<Map>()) {
        permissions[(row['skill_id'] ?? '').toString()] =
            row['connected'] == true;
      }
      if (permissions.isEmpty && local.isNotEmpty) {
        return local.map((key, value) => MapEntry(key, value == true));
      }
      await _storage.saveJson(userId, 'skill_permissions', permissions);
      return permissions;
    } catch (_) {
      return local.map((key, value) => MapEntry(key, value == true));
    }
  }

  Future<void> _saveSkillPermissions(
    String userId,
    List<AuraSkill> skills,
  ) async {
    final payload = {
      for (final skill in skills) skill.id: skill.permission,
    };
    await _storage.saveJson(userId, 'skill_permissions', payload);
    final supabase = _client;
    if (supabase == null) return;

    try {
      await supabase.from('skills').delete().eq('user_id', userId);
      await supabase.from('skills').insert(
            skills
                .map(
                  (skill) => {
                    'id': '$userId:${skill.id}',
                    'user_id': userId,
                    'skill_id': skill.id,
                    'title': skill.title,
                    'connected': skill.permission,
                    'updated_at': DateTime.now().toIso8601String(),
                    'payload': {
                      'id': skill.id,
                      'title': skill.title,
                      'subtitle': skill.subtitle,
                      'connected': skill.permission,
                    },
                  },
                )
                .toList(),
          );
    } catch (_) {}
  }

  Future<String?> _loadSelectedWorldClock(String userId) async {
    final local = _storage.getJson(userId, 'world_clock')?['selected_id'];
    final supabase = _client;
    if (supabase == null) return local?.toString();
    try {
      final response = await supabase
          .from('world_clocks')
          .select('selected_clock_id')
          .eq('user_id', userId)
          .maybeSingle();
      return (response?['selected_clock_id'] ?? local)?.toString();
    } catch (_) {
      return local?.toString();
    }
  }

  Future<void> _saveSelectedWorldClock(String userId, String selectedId) async {
    await _storage.saveJson(userId, 'world_clock', {'selected_id': selectedId});
    final supabase = _client;
    if (supabase == null) return;
    try {
      await supabase.from('world_clocks').upsert({
        'id': userId,
        'user_id': userId,
        'selected_clock_id': selectedId,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<AuraPrivacy?> _loadPrivacy(String userId) async {
    final local = _storage.getJson(userId, 'privacy');
    final supabase = _client;
    if (supabase == null) {
      return local == null ? null : ModelCodecs.privacyFromJson(local);
    }

    try {
      final response = await supabase
          .from('user_settings')
          .select('privacy_payload')
          .eq('user_id', userId)
          .maybeSingle();
      final payload = response?['privacy_payload'];
      if (payload is Map) {
        final json = payload.cast<String, dynamic>();
        await _storage.saveJson(userId, 'privacy', json);
        return ModelCodecs.privacyFromJson(json);
      }
    } catch (_) {}
    return local == null ? null : ModelCodecs.privacyFromJson(local);
  }

  Future<void> _savePrivacy(String userId, AuraPrivacy privacy) async {
    final payload = ModelCodecs.privacyToJson(privacy);
    await _storage.saveJson(userId, 'privacy', payload);
    final supabase = _client;
    if (supabase == null) return;
    try {
      await supabase.from('user_settings').upsert({
        'user_id': userId,
        'privacy_payload': payload,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Map<String, dynamic> _encodeDynamic<T>(T item) {
    if (item is AuraList) return ModelCodecs.listToJson(item);
    if (item is AuraNote) return ModelCodecs.noteToJson(item);
    if (item is AuraAlarm) return ModelCodecs.alarmToJson(item);
    if (item is AuraTimerItem) return ModelCodecs.timerToJson(item);
    if (item is AuraAccount) return ModelCodecs.accountToJson(item);
    if (item is AuraActivity) return ModelCodecs.activityToJson(item);
    if (item is AuraNotification) return ModelCodecs.notificationToJson(item);
    if (item is AuraNetworkItem) return ModelCodecs.networkToJson(item);
    return const <String, dynamic>{};
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
