import 'package:flutter/material.dart';

enum AuraDeviceType {
  light,
  tv,
  speaker,
  ac,
  plug,
  camera,
  lock,
  sensor,
  curtain,
  vacuum,
  thermostat,
  hub,
}

enum AuraConnectionType { wifi, bluetooth, zigbee }

extension AuraConnectionTypeLabel on AuraConnectionType {
  String get label {
    return switch (this) {
      AuraConnectionType.wifi => 'Wi-Fi',
      AuraConnectionType.bluetooth => 'Bluetooth',
      AuraConnectionType.zigbee => 'Zigbee',
    };
  }
}

enum AuraRoutineKind { turnOffAt, turnOnAt, custom }

class AuraRoutine {
  AuraRoutine({
    required this.id,
    required this.title,
    required this.kind,
    required this.time,
    this.enabled = true,
  });

  final String id;
  String title;
  AuraRoutineKind kind;
  String time;
  bool enabled;
}

class AuraDevice {
  AuraDevice({
    required this.id,
    required this.name,
    required this.room,
    required this.status,
    required this.active,
    required this.type,
    AuraConnectionType connection = AuraConnectionType.wifi,
    Set<AuraConnectionType>? connections,
    this.value,
    this.colorHex = 0xFFFACC15,
    this.supportsColor = true,
    this.supportsDimming = true,
    this.manufacturer = '',
    this.model = '',
    this.groupId = '',
    this.tvVolume = 50,
    this.tvChannel = 5,
    this.tvBrightness = 80,
    this.tvContrast = 70,
    this.tvColorTemperature = 'Normal',
    this.hdmiCec = true,
    this.acMode = 'Resfriar',
    this.fanSpeed = 'Auto',
    this.ecoMode = false,
    this.turboMode = false,
    this.sleepMode = false,
    this.adaptiveBrightness = true,
    List<AuraRoutine>? routines,
  })  : connections = connections ?? {connection},
        routines = routines ?? [];

  final String id;
  String name;
  String room;
  String status;
  bool active;
  final AuraDeviceType type;
  Set<AuraConnectionType> connections;
  int? value;
  int colorHex;
  bool supportsColor;
  bool supportsDimming;
  String manufacturer;
  String model;
  String groupId;
  int tvVolume;
  int tvChannel;
  int tvBrightness;
  int tvContrast;
  String tvColorTemperature;
  bool hdmiCec;
  String acMode;
  String fanSpeed;
  bool ecoMode;
  bool turboMode;
  bool sleepMode;
  bool adaptiveBrightness;
  final List<AuraRoutine> routines;

  IconData get icon {
    return switch (type) {
      AuraDeviceType.light => Icons.lightbulb_outline_rounded,
      AuraDeviceType.tv => Icons.tv_rounded,
      AuraDeviceType.speaker => Icons.speaker_rounded,
      AuraDeviceType.ac => Icons.thermostat_rounded,
      AuraDeviceType.plug => Icons.power_rounded,
      AuraDeviceType.camera => Icons.videocam_rounded,
      AuraDeviceType.lock => Icons.lock_rounded,
      AuraDeviceType.sensor => Icons.sensors_rounded,
      AuraDeviceType.curtain => Icons.curtains_rounded,
      AuraDeviceType.vacuum => Icons.cleaning_services_rounded,
      AuraDeviceType.thermostat => Icons.device_thermostat_rounded,
      AuraDeviceType.hub => Icons.hub_rounded,
    };
  }

  String get typeLabel {
    return switch (type) {
      AuraDeviceType.light => 'Lâmpada inteligente',
      AuraDeviceType.tv => 'Smart TV',
      AuraDeviceType.speaker => 'Alto-falante',
      AuraDeviceType.ac => 'Ar-condicionado',
      AuraDeviceType.plug => 'Tomada inteligente',
      AuraDeviceType.camera => 'Câmera',
      AuraDeviceType.lock => 'Fechadura',
      AuraDeviceType.sensor => 'Sensor',
      AuraDeviceType.curtain => 'Cortina',
      AuraDeviceType.vacuum => 'Aspirador robô',
      AuraDeviceType.thermostat => 'Termostato',
      AuraDeviceType.hub => 'Hub Zigbee',
    };
  }

  String get connectionLabel {
    final values = connections.isEmpty ? {AuraConnectionType.wifi} : connections;
    return values.map((connection) => connection.label).join(' + ');
  }

  AuraConnectionType get connection =>
      connections.isEmpty ? AuraConnectionType.wifi : connections.first;

  set connection(AuraConnectionType value) {
    connections = {value};
  }

  void refreshStatus() {
    if (!active) {
      status = 'Desligado';
      return;
    }

    status = switch (type) {
      AuraDeviceType.light => supportsDimming
          ? 'Ligado • ${value ?? 100}%'
          : 'Ligado • branco fixo',
      AuraDeviceType.ac => '${value ?? 23}°C • $acMode',
      AuraDeviceType.speaker => 'Pausado',
      AuraDeviceType.tv => 'Canal $tvChannel • Volume $tvVolume%',
      AuraDeviceType.plug => 'Ligado • energia ativa',
      AuraDeviceType.camera => 'Online • monitorando',
      AuraDeviceType.lock => 'Travada',
      AuraDeviceType.sensor => 'Ativo • sem alerta',
      AuraDeviceType.curtain => 'Aberta • ${value ?? 100}%',
      AuraDeviceType.vacuum => 'Pronto para limpar',
      AuraDeviceType.thermostat => '${value ?? 23}°C • automático',
      AuraDeviceType.hub => 'Online • Zigbee',
    };
  }
}

class AuraContact {
  AuraContact({
    required this.id,
    required this.name,
    required this.time,
    required this.type,
    this.phone = '',
    this.imageAsset,
  });

  final String id;
  String name;
  String time;
  String type;
  String phone;
  String? imageAsset;
}

class AuraMedia {
  AuraMedia({
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.isPlaying,
    this.id = '',
    this.source = '',
    this.audioUrl = '',
    this.videoId = '',
    this.youtubeUrl = '',
    this.spotifyUrl = '',
    this.duration = Duration.zero,
    this.position = Duration.zero,
  });

  String id;
  String title;
  String artist;
  String imageUrl;
  String source;
  String audioUrl;
  bool isPlaying;
  String videoId;
  String youtubeUrl;
  String spotifyUrl;
  Duration duration;
  Duration position;

  bool get hasPlayableAudio => audioUrl.trim().isNotEmpty;
  bool get hasPlayableVideo => videoId.trim().isNotEmpty || youtubeUrl.trim().isNotEmpty;
  bool get hasAnyMedia => hasPlayableAudio || hasPlayableVideo;
}

class AuraListItem {
  AuraListItem({required this.id, required this.text, required this.checked});

  final String id;
  String text;
  bool checked;
}

class AuraList {
  AuraList({required this.id, required this.title, required this.items});

  final String id;
  String title;
  final List<AuraListItem> items;
}

class AuraNote {
  AuraNote({required this.id, required this.title, required this.preview});

  final String id;
  String title;
  String preview;
}

class AuraAlarm {
  AuraAlarm({
    required this.id,
    required this.time,
    required this.label,
    required this.active,
    this.name = 'Alarme',
    List<String>? days,
    this.tone = 'Radar',
    this.source = 'Aura',
    this.snoozeMinutes = 10,
    this.vibrate = true,
    this.volume = 100,
    this.ringDurationSeconds = 90,
  }) : days = days ?? ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];

  final String id;
  String time;
  String label;
  bool active;
  String name;
  List<String> days;
  String tone;
  String source;
  int snoozeMinutes;
  bool vibrate;
  int volume;
  int ringDurationSeconds;
  DateTime? lastTriggeredAt;
  DateTime? snoozedUntil;

  DateTime nextOccurrence([DateTime? from]) {
    final base = from ?? DateTime.now();
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 8;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    var next = DateTime(base.year, base.month, base.day, hour, minute);
    for (var i = 0; i < 8; i++) {
      if (next.isAfter(base) && _matchesDay(next)) return next;
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  bool shouldTrigger(DateTime now) {
    final snooze = snoozedUntil;
    if (snooze != null &&
        !now.isBefore(DateTime(snooze.year, snooze.month, snooze.day, snooze.hour, snooze.minute))) {
      return !_triggeredThisMinute(now);
    }

    final parts = time.split(':');
    if (parts.length < 2) return false;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;
    if (now.hour != hour || now.minute != minute) return false;
    if (!_matchesDay(now)) return false;
    return !_triggeredThisMinute(now);
  }

  bool _triggeredThisMinute(DateTime now) {
    final last = lastTriggeredAt;
    if (last == null) return false;
    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day &&
        last.hour == now.hour &&
        last.minute == now.minute;
  }

  bool _matchesDay(DateTime value) {
    if (days.isEmpty) return true;
    const labels = {
      DateTime.monday: 'Seg',
      DateTime.tuesday: 'Ter',
      DateTime.wednesday: 'Qua',
      DateTime.thursday: 'Qui',
      DateTime.friday: 'Sex',
      DateTime.saturday: 'Sab',
      DateTime.sunday: 'Dom',
    };
    final label = labels[value.weekday];
    if (label == null) return true;
    return days.map(_normalizeDay).contains(_normalizeDay(label));
  }

  static String _normalizeDay(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('Ã¡', 'a')
        .replaceAll('Ã£', 'a')
        .replaceAll('é', 'e')
        .replaceAll('Ã©', 'e')
        .trim();
  }
}

class AuraTimerItem {
  AuraTimerItem({
    required this.id,
    required String duration,
    required this.label,
    required this.active,
    this.preset = false,
  }) : totalSeconds = parseDuration(duration),
       remainingSeconds = parseDuration(duration);

  final String id;
  String label;
  bool active;
  bool preset;
  int totalSeconds;
  int remainingSeconds;
  bool completed = false;
  int elapsedAfterFinishSeconds = 0;
  DateTime? completedAt;

  String get duration => formatDuration(remainingSeconds);

  String get totalDuration => formatDuration(totalSeconds);

  void setDuration(String value) {
    final seconds = parseDuration(value);
    totalSeconds = seconds;
    remainingSeconds = seconds;
    active = false;
    completed = false;
  }

  void reset() {
    remainingSeconds = totalSeconds;
    active = false;
    completed = false;
    elapsedAfterFinishSeconds = 0;
    completedAt = null;
  }

  static int parseDuration(String value) {
    final parts = value
        .split(':')
        .map((part) => int.tryParse(part.trim()) ?? 0)
        .toList();
    if (parts.length >= 3) {
      return (parts[0] * 3600) + (parts[1] * 60) + parts[2];
    }
    if (parts.length == 2) {
      return (parts[0] * 60) + parts[1];
    }
    if (parts.length == 1 && parts.first > 0) {
      return parts.first * 60;
    }
    return 60;
  }

  static String formatDuration(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;
    final hours = safeSeconds ~/ 3600;
    final minutes = (safeSeconds % 3600) ~/ 60;
    final remaining = safeSeconds % 60;
    return [
      hours.toString().padLeft(2, '0'),
      minutes.toString().padLeft(2, '0'),
      remaining.toString().padLeft(2, '0'),
    ].join(':');
  }
}

class AuraReminder {
  AuraReminder({
    required this.id,
    required this.text,
    this.time,
    this.endTime,
    this.repeat = 'none',
    this.alertMinutesBefore = 0,
    this.active = true,
  });

  final String id;
  String text;
  String? time;
  String? endTime;
  String repeat;
  int alertMinutesBefore;
  bool active;
  DateTime? lastTriggeredAt;
}

class AuraStopwatchState {
  bool active = false;
  int elapsedSeconds = 0;
  final List<int> laps = [];

  String get displayTime => AuraTimerItem.formatDuration(elapsedSeconds);

  void reset() {
    active = false;
    elapsedSeconds = 0;
    laps.clear();
  }
}

class AuraAccount {
  AuraAccount({
    required this.id,
    required this.name,
    required this.role,
    this.imageAsset,
    this.imagePath,
    this.email = '',
    this.notificationsEnabled = true,
    this.canManageDevices = true,
    this.canManageMembers = false,
    this.canUseVoice = true,
    this.canUseMedia = true,
    this.canViewHistory = false,
    this.phone = '',
    this.groupId = '',
    this.joinedAt,
    this.lastLogin,
    AuraPrivacy? privacy,
  }) : privacy = privacy ?? AuraPrivacy();

  final String id;
  String name;
  String role;
  String? imageAsset;
  String? imagePath;
  String email;
  String phone;
  String groupId;
  bool notificationsEnabled;
  bool canManageDevices;
  bool canManageMembers;
  bool canUseVoice;
  bool canUseMedia;
  bool canViewHistory;
  DateTime? joinedAt;
  DateTime? lastLogin;
  final AuraPrivacy privacy;
}

class AuraGroup {
  AuraGroup({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.inviteCode,
    this.memberIds = const [],
    this.imageAsset,
    this.imagePath,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String ownerId;
  String name;
  String inviteCode;
  List<String> memberIds;
  String? imageAsset;
  String? imagePath;
  DateTime? createdAt;
  DateTime? updatedAt;
}

class AuraMessage {
  AuraMessage({
    required this.id,
    required this.userId,
    required this.body,
    required this.direction,
    required this.createdAt,
    this.contactId = '',
    this.groupId = '',
    this.status = 'sent',
  });

  final String id;
  final String userId;
  String body;
  String direction;
  String contactId;
  String groupId;
  String status;
  DateTime createdAt;
}

class AuraCallSession {
  AuraCallSession({
    required this.id,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.contactId = '',
    this.groupId = '',
    this.endedAt,
  });

  final String id;
  final String userId;
  String status;
  String contactId;
  String groupId;
  DateTime createdAt;
  DateTime? endedAt;
}

class AuraRolePermissions {
  const AuraRolePermissions({
    required this.canManageDevices,
    required this.canManageMembers,
    required this.canUseVoice,
    required this.canUseMedia,
    required this.canViewHistory,
  });

  final bool canManageDevices;
  final bool canManageMembers;
  final bool canUseVoice;
  final bool canUseMedia;
  final bool canViewHistory;
}

class AuraSkill {
  AuraSkill({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.connectUrl = '',
    this.permission = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String connectUrl;
  bool permission;
}

class AuraActivity {
  AuraActivity({
    required this.id,
    required this.time,
    required this.text,
    required this.device,
    required this.origin,
    required this.details,
  });

  final String id;
  String time;
  String text;
  String device;
  String origin;
  String details;
}

class AuraNetworkItem {
  AuraNetworkItem({
    required this.id,
    required this.name,
    required this.type,
    required this.available,
    this.signal = '',
    this.connected = false,
  });

  final String id;
  String name;
  String type;
  String signal;
  bool available;
  bool connected;
}

class AuraNotificationTone {
  AuraNotificationTone({
    required this.id,
    required this.title,
    required this.description,
    this.assetPath,
    this.systemPicker = false,
  });

  final String id;
  final String title;
  final String description;
  final String? assetPath;
  final bool systemPicker;
}

class AuraWorldClock {
  const AuraWorldClock({
    required this.id,
    required this.country,
    required this.city,
    required this.utcOffsetMinutes,
    this.latitude = 0,
    this.longitude = 0,
  });

  final String id;
  final String country;
  final String city;
  final int utcOffsetMinutes;
  final double latitude;
  final double longitude;

  String get label => '$country • $city';
}

class AuraNotification {
  AuraNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.device = '',
    this.origin = '',
    this.read = false,
  });

  final String id;
  String title;
  String body;
  DateTime timestamp;
  String device;
  String origin;
  bool read;
}

class AuraPrivacy {
  AuraPrivacy({
    this.allowLocationTracking = false,
    this.allowAnalytics = false,
    this.allowThirdPartyIntegration = false,
    this.dataRetentionDays = 90,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.profileVisibility = 'private',
  });

  bool allowLocationTracking;
  bool allowAnalytics;
  bool allowThirdPartyIntegration;
  int dataRetentionDays;
  bool emailNotifications;
  bool pushNotifications;
  String profileVisibility;
}
