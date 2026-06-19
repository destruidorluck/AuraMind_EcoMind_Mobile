import '../../models/aura_models.dart';

class ModelCodecs {
  const ModelCodecs._();

  static AuraContact contactFromJson(Map<String, dynamic> json) {
    return AuraContact(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      time: (json['time'] ?? 'Celular').toString(),
      type: (json['type'] ?? 'Contato').toString(),
      imageAsset: (json['image_asset'] ?? json['avatar_url'] ?? '')
              .toString()
              .trim()
              .isEmpty
          ? null
          : (json['image_asset'] ?? json['avatar_url']).toString(),
    );
  }

  static Map<String, dynamic> contactToJson(AuraContact contact) {
    return {
      'id': contact.id,
      'name': contact.name,
      'phone': contact.phone,
      'time': contact.time,
      'type': contact.type,
      'image_asset': contact.imageAsset,
    };
  }

  static AuraRoutine routineFromJson(Map<String, dynamic> json) {
    final kindRaw = (json['kind'] ?? AuraRoutineKind.custom.name).toString();
    return AuraRoutine(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      kind: AuraRoutineKind.values.firstWhere(
        (item) => item.name == kindRaw,
        orElse: () => AuraRoutineKind.custom,
      ),
      time: (json['time'] ?? '22:00').toString(),
      enabled: json['enabled'] == true,
    );
  }

  static Map<String, dynamic> routineToJson(AuraRoutine routine) {
    return {
      'id': routine.id,
      'title': routine.title,
      'kind': routine.kind.name,
      'time': routine.time,
      'enabled': routine.enabled,
    };
  }

  static AuraDevice deviceFromJson(Map<String, dynamic> json) {
    final typeRaw = (json['type'] ?? AuraDeviceType.light.name).toString();
    final type = AuraDeviceType.values.firstWhere(
      (item) => item.name == typeRaw,
      orElse: () => AuraDeviceType.light,
    );
    final connectionList = (json['connections'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .map(
          (name) => AuraConnectionType.values.firstWhere(
            (value) => value.name == name,
            orElse: () => AuraConnectionType.wifi,
          ),
        )
        .toSet();

    return AuraDevice(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      room: (json['room'] ?? 'Casa').toString(),
      status: (json['status'] ?? 'Desligado').toString(),
      active: json['active'] == true,
      type: type,
      connections: connectionList.isEmpty
          ? {AuraConnectionType.wifi}
          : connectionList,
      value: json['value'] is num ? (json['value'] as num).round() : null,
      colorHex: json['colorHex'] is num
          ? (json['colorHex'] as num).toInt()
          : 0xFFFACC15,
      supportsColor: json['supportsColor'] != false,
      supportsDimming: json['supportsDimming'] != false,
      manufacturer: (json['manufacturer'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      groupId: (json['group_id'] ?? '').toString(),
      tvVolume: json['tvVolume'] is num ? (json['tvVolume'] as num).toInt() : 50,
      tvChannel: json['tvChannel'] is num
          ? (json['tvChannel'] as num).toInt()
          : 5,
      tvBrightness: json['tvBrightness'] is num
          ? (json['tvBrightness'] as num).toInt()
          : 80,
      tvContrast: json['tvContrast'] is num
          ? (json['tvContrast'] as num).toInt()
          : 70,
      tvColorTemperature: (json['tvColorTemperature'] ?? 'Normal').toString(),
      hdmiCec: json['hdmiCec'] != false,
      acMode: (json['acMode'] ?? 'Resfriar').toString(),
      fanSpeed: (json['fanSpeed'] ?? 'Auto').toString(),
      ecoMode: json['ecoMode'] == true,
      turboMode: json['turboMode'] == true,
      sleepMode: json['sleepMode'] == true,
      adaptiveBrightness: json['adaptiveBrightness'] != false,
      routines: (json['routines'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => routineFromJson(item.cast<String, dynamic>()))
          .toList(),
    );
  }

  static Map<String, dynamic> deviceToJson(AuraDevice device) {
    return {
      'id': device.id,
      'name': device.name,
      'room': device.room,
      'status': device.status,
      'active': device.active,
      'type': device.type.name,
      'connections': device.connections.map((item) => item.name).toList(),
      'value': device.value,
      'colorHex': device.colorHex,
      'supportsColor': device.supportsColor,
      'supportsDimming': device.supportsDimming,
      'manufacturer': device.manufacturer,
      'model': device.model,
      'group_id': device.groupId,
      'tvVolume': device.tvVolume,
      'tvChannel': device.tvChannel,
      'tvBrightness': device.tvBrightness,
      'tvContrast': device.tvContrast,
      'tvColorTemperature': device.tvColorTemperature,
      'hdmiCec': device.hdmiCec,
      'acMode': device.acMode,
      'fanSpeed': device.fanSpeed,
      'ecoMode': device.ecoMode,
      'turboMode': device.turboMode,
      'sleepMode': device.sleepMode,
      'adaptiveBrightness': device.adaptiveBrightness,
      'routines': device.routines.map(routineToJson).toList(),
    };
  }

  static AuraList listFromJson(Map<String, dynamic> json) {
    return AuraList(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map((item) => listItemFromJson(item.cast<String, dynamic>()))
          .toList(),
    );
  }

  static Map<String, dynamic> listToJson(AuraList list) {
    return {
      'id': list.id,
      'title': list.title,
      'items': list.items.map(listItemToJson).toList(),
    };
  }

  static AuraListItem listItemFromJson(Map<String, dynamic> json) {
    return AuraListItem(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      checked: json['checked'] == true,
    );
  }

  static Map<String, dynamic> listItemToJson(AuraListItem item) {
    return {
      'id': item.id,
      'text': item.text,
      'checked': item.checked,
    };
  }

  static AuraNote noteFromJson(Map<String, dynamic> json) {
    return AuraNote(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      preview: (json['preview'] ?? json['body'] ?? '').toString(),
    );
  }

  static Map<String, dynamic> noteToJson(AuraNote note) {
    return {
      'id': note.id,
      'title': note.title,
      'preview': note.preview,
    };
  }

  static AuraAlarm alarmFromJson(Map<String, dynamic> json) {
    final alarm = AuraAlarm(
      id: (json['id'] ?? '').toString(),
      time: (json['time'] ?? '08:00').toString(),
      label: (json['label'] ?? 'Todos os dias').toString(),
      active: json['active'] == true,
      name: (json['name'] ?? 'Alarme').toString(),
      days: (json['days'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      tone: (json['tone'] ?? 'Radar').toString(),
      source: (json['source'] ?? 'Aura').toString(),
      snoozeMinutes: json['snooze_minutes'] is num
          ? (json['snooze_minutes'] as num).round()
          : 10,
      vibrate: json['vibrate'] != false,
      volume: json['volume'] is num ? (json['volume'] as num).round() : 100,
      ringDurationSeconds: json['ring_duration_seconds'] is num
          ? (json['ring_duration_seconds'] as num).round()
          : 90,
    );
    final lastTriggered = DateTime.tryParse(
      (json['last_triggered_at'] ?? '').toString(),
    );
    alarm.lastTriggeredAt = lastTriggered;
    alarm.snoozedUntil = DateTime.tryParse(
      (json['snoozed_until'] ?? '').toString(),
    );
    return alarm;
  }

  static Map<String, dynamic> alarmToJson(AuraAlarm alarm) {
    return {
      'id': alarm.id,
      'time': alarm.time,
      'label': alarm.label,
      'active': alarm.active,
      'name': alarm.name,
      'days': alarm.days,
      'tone': alarm.tone,
      'source': alarm.source,
      'snooze_minutes': alarm.snoozeMinutes,
      'vibrate': alarm.vibrate,
      'volume': alarm.volume,
      'ring_duration_seconds': alarm.ringDurationSeconds,
      'last_triggered_at': alarm.lastTriggeredAt?.toIso8601String(),
      'snoozed_until': alarm.snoozedUntil?.toIso8601String(),
    };
  }

  static AuraTimerItem timerFromJson(Map<String, dynamic> json) {
    final timer = AuraTimerItem(
      id: (json['id'] ?? '').toString(),
      duration: (json['total_duration'] ?? json['duration'] ?? '00:15:00')
          .toString(),
      label: (json['label'] ?? 'Timer').toString(),
      active: json['active'] == true,
      preset: json['preset'] == true,
    );
    final totalSeconds = json['total_seconds'];
    final remainingSeconds = json['remaining_seconds'];
    if (totalSeconds is num) timer.totalSeconds = totalSeconds.round();
    if (remainingSeconds is num) {
      timer.remainingSeconds = remainingSeconds.round();
    }
    timer.completed = json['completed'] == true;
    final elapsedAfterFinishSeconds = json['elapsed_after_finish_seconds'];
    if (elapsedAfterFinishSeconds is num) {
      timer.elapsedAfterFinishSeconds = elapsedAfterFinishSeconds.round();
    }
    timer.completedAt = DateTime.tryParse(
      (json['completed_at'] ?? '').toString(),
    );
    return timer;
  }

  static Map<String, dynamic> timerToJson(AuraTimerItem timer) {
    return {
      'id': timer.id,
      'label': timer.label,
      'active': timer.active,
      'preset': timer.preset,
      'total_seconds': timer.totalSeconds,
      'remaining_seconds': timer.remainingSeconds,
      'completed': timer.completed,
      'elapsed_after_finish_seconds': timer.elapsedAfterFinishSeconds,
      'completed_at': timer.completedAt?.toIso8601String(),
      'duration': timer.duration,
      'total_duration': timer.totalDuration,
    };
  }

  static AuraReminder reminderFromJson(Map<String, dynamic> json) {
    final reminder = AuraReminder(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      time: (json['time'] ?? '').toString().trim().isEmpty
          ? null
          : (json['time'] ?? '').toString(),
      endTime: (json['end_time'] ?? '').toString().trim().isEmpty
          ? null
          : (json['end_time'] ?? '').toString(),
      repeat: (json['repeat'] ?? 'none').toString(),
      alertMinutesBefore: json['alert_minutes_before'] is num
          ? (json['alert_minutes_before'] as num).round()
          : 0,
      active: json['active'] != false,
    );
    reminder.lastTriggeredAt = DateTime.tryParse(
      (json['last_triggered_at'] ?? '').toString(),
    );
    return reminder;
  }

  static Map<String, dynamic> reminderToJson(AuraReminder reminder) {
    return {
      'id': reminder.id,
      'text': reminder.text,
      'time': reminder.time,
      'end_time': reminder.endTime,
      'repeat': reminder.repeat,
      'alert_minutes_before': reminder.alertMinutesBefore,
      'active': reminder.active,
      'last_triggered_at': reminder.lastTriggeredAt?.toIso8601String(),
    };
  }

  static AuraAccount accountFromJson(Map<String, dynamic> json) {
    return AuraAccount(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Membro').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'Membro').toString(),
      imageAsset: (json['image_asset'] ?? json['avatar_url'] ?? '')
              .toString()
              .trim()
              .isEmpty
          ? null
          : (json['image_asset'] ?? json['avatar_url']).toString(),
      imagePath: (json['image_path'] ?? json['avatar_path'] ?? '')
              .toString()
              .trim()
              .isEmpty
          ? null
          : (json['image_path'] ?? json['avatar_path']).toString(),
      notificationsEnabled: json['notifications_enabled'] != false,
      canManageDevices: json['can_manage_devices'] == true,
      canManageMembers: json['can_manage_members'] == true,
      canUseVoice: json['can_use_voice'] != false,
      canUseMedia: json['can_use_media'] != false,
      canViewHistory: json['can_view_history'] == true,
      phone: (json['phone'] ?? '').toString(),
      groupId: (json['group_id'] ?? '').toString(),
      joinedAt: DateTime.tryParse((json['joined_at'] ?? '').toString()),
      lastLogin: DateTime.tryParse((json['last_login'] ?? '').toString()),
      privacy: privacyFromJson(
        (json['privacy'] is Map ? json['privacy'] : const <String, dynamic>{})
            as Map<String, dynamic>,
      ),
    );
  }

  static Map<String, dynamic> accountToJson(AuraAccount account) {
    return {
      'id': account.id,
      'name': account.name,
      'email': account.email,
      'role': account.role,
      'image_asset': account.imageAsset,
      'image_path': account.imagePath,
      'avatar_url': account.imageAsset,
      'avatar_path': account.imagePath,
      'notifications_enabled': account.notificationsEnabled,
      'can_manage_devices': account.canManageDevices,
      'can_manage_members': account.canManageMembers,
      'can_use_voice': account.canUseVoice,
      'can_use_media': account.canUseMedia,
      'can_view_history': account.canViewHistory,
      'phone': account.phone,
      'group_id': account.groupId,
      'joined_at': account.joinedAt?.toIso8601String(),
      'last_login': account.lastLogin?.toIso8601String(),
      'privacy': privacyToJson(account.privacy),
    };
  }

  static AuraGroup groupFromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    final merged = {
      ...json,
      if (payload is Map) ...payload.cast<String, dynamic>(),
    };
    return AuraGroup(
      id: (merged['id'] ?? '').toString(),
      ownerId: (merged['owner_id'] ?? '').toString(),
      name: (merged['name'] ?? 'Aura Mind').toString(),
      inviteCode: (merged['invite_code'] ?? '').toString(),
      imageAsset: (merged['image_asset'] ?? merged['image_url'] ?? '')
              .toString()
              .trim()
              .isEmpty
          ? null
          : (merged['image_asset'] ?? merged['image_url']).toString(),
      imagePath: (merged['image_path'] ?? merged['avatar_path'] ?? '')
              .toString()
              .trim()
              .isEmpty
          ? null
          : (merged['image_path'] ?? merged['avatar_path']).toString(),
      memberIds: (merged['member_ids'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      createdAt: DateTime.tryParse((merged['created_at'] ?? '').toString()),
      updatedAt: DateTime.tryParse((merged['updated_at'] ?? '').toString()),
    );
  }

  static Map<String, dynamic> groupToJson(AuraGroup group) {
    return {
      'id': group.id,
      'owner_id': group.ownerId,
      'name': group.name,
      'invite_code': group.inviteCode,
      'image_asset': group.imageAsset,
      'image_path': group.imagePath,
      'member_ids': group.memberIds,
      'created_at': group.createdAt?.toIso8601String(),
      'updated_at': group.updatedAt?.toIso8601String(),
    };
  }

  static AuraMessage messageFromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    final merged = {
      ...json,
      if (payload is Map) ...payload.cast<String, dynamic>(),
    };
    return AuraMessage(
      id: (merged['id'] ?? '').toString(),
      userId: (merged['user_id'] ?? '').toString(),
      contactId: (merged['contact_id'] ?? '').toString(),
      groupId: (merged['group_id'] ?? '').toString(),
      direction: (merged['direction'] ?? 'outgoing').toString(),
      body: (merged['body'] ?? '').toString(),
      status: (merged['status'] ?? 'sent').toString(),
      createdAt:
          DateTime.tryParse((merged['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  static Map<String, dynamic> messageToJson(AuraMessage message) {
    return {
      'id': message.id,
      'user_id': message.userId,
      'contact_id': message.contactId,
      'group_id': message.groupId,
      'direction': message.direction,
      'body': message.body,
      'status': message.status,
      'created_at': message.createdAt.toIso8601String(),
    };
  }

  static AuraCallSession callSessionFromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    final merged = {
      ...json,
      if (payload is Map) ...payload.cast<String, dynamic>(),
    };
    return AuraCallSession(
      id: (merged['id'] ?? '').toString(),
      userId: (merged['user_id'] ?? '').toString(),
      contactId: (merged['contact_id'] ?? '').toString(),
      groupId: (merged['group_id'] ?? '').toString(),
      status: (merged['status'] ?? 'ringing').toString(),
      createdAt:
          DateTime.tryParse((merged['created_at'] ?? '').toString()) ??
          DateTime.now(),
      endedAt: DateTime.tryParse((merged['ended_at'] ?? '').toString()),
    );
  }

  static Map<String, dynamic> callSessionToJson(AuraCallSession session) {
    return {
      'id': session.id,
      'user_id': session.userId,
      'contact_id': session.contactId,
      'group_id': session.groupId,
      'status': session.status,
      'created_at': session.createdAt.toIso8601String(),
      'ended_at': session.endedAt?.toIso8601String(),
    };
  }

  static AuraActivity activityFromJson(Map<String, dynamic> json) {
    return AuraActivity(
      id: (json['id'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      device: (json['device'] ?? '').toString(),
      origin: (json['origin'] ?? '').toString(),
      details: (json['details'] ?? '').toString(),
    );
  }

  static Map<String, dynamic> activityToJson(AuraActivity activity) {
    return {
      'id': activity.id,
      'time': activity.time,
      'text': activity.text,
      'device': activity.device,
      'origin': activity.origin,
      'details': activity.details,
    };
  }

  static AuraNotification notificationFromJson(Map<String, dynamic> json) {
    return AuraNotification(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      timestamp:
          DateTime.tryParse((json['timestamp'] ?? '').toString()) ??
          DateTime.now(),
      device: (json['device'] ?? '').toString(),
      origin: (json['origin'] ?? '').toString(),
      read: json['read'] == true,
    );
  }

  static Map<String, dynamic> notificationToJson(AuraNotification item) {
    return {
      'id': item.id,
      'title': item.title,
      'body': item.body,
      'timestamp': item.timestamp.toIso8601String(),
      'device': item.device,
      'origin': item.origin,
      'read': item.read,
    };
  }

  static AuraNetworkItem networkFromJson(Map<String, dynamic> json) {
    return AuraNetworkItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['network_name'] ?? '').toString(),
      type: (json['type'] ?? json['connection_type'] ?? '').toString(),
      signal: (json['signal'] ?? '').toString(),
      available: json['available'] != false,
      connected:
          json['connected'] == true || (json['status'] ?? '') == 'connected',
    );
  }

  static Map<String, dynamic> networkToJson(AuraNetworkItem item) {
    return {
      'id': item.id,
      'name': item.name,
      'type': item.type,
      'signal': item.signal,
      'available': item.available,
      'connected': item.connected,
      'status': item.connected ? 'connected' : 'available',
    };
  }

  static AuraPrivacy privacyFromJson(Map<String, dynamic> json) {
    return AuraPrivacy(
      allowLocationTracking: json['allow_location_tracking'] == true,
      allowAnalytics: json['allow_analytics'] == true,
      allowThirdPartyIntegration:
          json['allow_third_party_integration'] == true,
      dataRetentionDays: json['data_retention_days'] is num
          ? (json['data_retention_days'] as num).round()
          : 90,
      emailNotifications: json['email_notifications'] != false,
      pushNotifications: json['push_notifications'] != false,
      profileVisibility: (json['profile_visibility'] ?? 'private').toString(),
    );
  }

  static Map<String, dynamic> privacyToJson(AuraPrivacy privacy) {
    return {
      'allow_location_tracking': privacy.allowLocationTracking,
      'allow_analytics': privacy.allowAnalytics,
      'allow_third_party_integration': privacy.allowThirdPartyIntegration,
      'data_retention_days': privacy.dataRetentionDays,
      'email_notifications': privacy.emailNotifications,
      'push_notifications': privacy.pushNotifications,
      'profile_visibility': privacy.profileVisibility,
    };
  }

  static AuraWorldClock worldClockFromJson(Map<String, dynamic> json) {
    return AuraWorldClock(
      id: (json['id'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      utcOffsetMinutes: json['utc_offset_minutes'] is num
          ? (json['utc_offset_minutes'] as num).round()
          : 0,
      latitude: json['latitude'] is num ? (json['latitude'] as num).toDouble() : 0,
      longitude:
          json['longitude'] is num ? (json['longitude'] as num).toDouble() : 0,
    );
  }

  static Map<String, dynamic> worldClockToJson(AuraWorldClock clock) {
    return {
      'id': clock.id,
      'country': clock.country,
      'city': clock.city,
      'utc_offset_minutes': clock.utcOffsetMinutes,
      'latitude': clock.latitude,
      'longitude': clock.longitude,
    };
  }
}
