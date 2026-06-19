import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/aura_models.dart';

class AuraNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _timeZonesInitialized = false;
  static final List<Map<String, Object?>> debugScheduledAlerts = [];

  static Future<void> initialize() async {
    if (_initialized) return;
    _initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    try {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestExactAlarmsPermission();
    } catch (_) {}
    _initialized = true;
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required String? payload,
    int id = 0,
  }) async {
    try {
      const android = AndroidNotificationDetails(
        'aura_notifications',
        'Notificações Aura Mind',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        color: Color(0xFF06B6D4), // Corrigido: Agora usa o objeto Color
      );
      const ios = DarwinNotificationDetails(presentSound: true);

      await _notifications.show(
        id,
        title,
        body,
        const NotificationDetails(android: android, iOS: ios),
        payload: payload,
      );
    } catch (_) {
      // Graceful fallback on web
      if (kIsWeb) {
        // Corrigido: Usando debugPrint no lugar de print para evitar avisos do linter
        debugPrint('Notification not available on web: $title - $body');
      }
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (_) {}
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (_) {}
  }

  static Future<void> showAlarmNotification({
    required String alarmName,
    required String time,
    String tone = 'Radar',
  }) async {
    await _showUrgentAlert(
      id: 100,
      title: 'Alarme: $alarmName',
      body: 'Hora de acordar! $time',
      payload: 'alarm:$alarmName',
      rawSound: _rawSoundForTone(tone, fallback: 'alarm_digital'),
    );
  }

  static Future<void> scheduleAlarm(AuraAlarm alarm) async {
    await cancelAlarm(alarm.id);
    if (!alarm.active) return;
    _initializeTimeZones();

    final days = alarm.days.isEmpty
        ? <String>['daily']
        : alarm.days.map((day) => day.trim()).where((day) => day.isNotEmpty);
    var index = 0;
    for (final day in days) {
      final next = day == 'daily'
          ? alarm.nextOccurrence()
          : _nextWeekdayOccurrence(alarm.time, day);
      await _scheduleUrgentAlert(
        id: _scheduledId('alarm', alarm.id, index),
        title: 'Alarme: ${alarm.name}',
        body: '${alarm.label} • ${alarm.time}',
        payload: 'alarm:${alarm.id}',
        when: next,
        rawSound: _rawSoundForTone(alarm.tone, fallback: 'alarm_digital'),
        matchDateTimeComponents: day == 'daily'
            ? DateTimeComponents.time
            : DateTimeComponents.dayOfWeekAndTime,
      );
      index += 1;
    }
  }

  static Future<void> cancelAlarm(String id) async {
    for (var index = 0; index < 8; index++) {
      await cancelNotification(_scheduledId('alarm', id, index));
    }
    debugScheduledAlerts.removeWhere(
      (item) => item['kind'] == 'alarm' && item['source_id'] == id,
    );
  }

  static Future<void> scheduleTimer(AuraTimerItem timer) async {
    await cancelTimer(timer.id);
    if (!timer.active || timer.remainingSeconds <= 0) return;
    _initializeTimeZones();
    final when = DateTime.now().add(Duration(seconds: timer.remainingSeconds));
    await _scheduleUrgentAlert(
      id: _scheduledId('timer', timer.id, 0),
      title: 'Timer finalizado',
      body: timer.label,
      payload: 'timer:${timer.id}',
      when: when,
      rawSound: _rawSoundForTone('Chime', fallback: 'chime'),
    );
  }

  static Future<void> cancelTimer(String id) async {
    await cancelNotification(_scheduledId('timer', id, 0));
    debugScheduledAlerts.removeWhere(
      (item) => item['kind'] == 'timer' && item['source_id'] == id,
    );
  }

  static Future<void> _scheduleUrgentAlert({
    required int id,
    required String title,
    required String body,
    required String payload,
    required DateTime when,
    required String rawSound,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    debugScheduledAlerts.removeWhere((item) => item['id'] == id);
    debugScheduledAlerts.add({
      'id': id,
      'kind': payload.split(':').first,
      'source_id': payload.contains(':') ? payload.split(':').last : payload,
      'title': title,
      'body': body,
      'when': when.toIso8601String(),
    });
    try {
      final android = AndroidNotificationDetails(
        'aura_alarms',
        'Alarmes e timers Aura Mind',
        channelDescription: 'Alertas importantes do Aura Mind',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(rawSound),
        color: const Color(0xFF06B6D4),
      );
      const ios = DarwinNotificationDetails(presentSound: true);
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(when, tz.local),
        NotificationDetails(android: android, iOS: ios),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
    } catch (_) {}
  }

  static Future<void> showTimerNotification({
    required String timerLabel,
    String tone = 'Chime',
  }) async {
    await _showUrgentAlert(
      id: 101,
      title: 'Timer finalizado',
      body: timerLabel,
      payload: 'timer:$timerLabel',
      rawSound: _rawSoundForTone(tone, fallback: 'chime'),
    );
  }

  static Future<void> _showUrgentAlert({
    required int id,
    required String title,
    required String body,
    required String payload,
    required String rawSound,
  }) async {
    try {
      final android = AndroidNotificationDetails(
        'aura_alarms',
        'Alarmes e timers Aura Mind',
        channelDescription: 'Alertas importantes do Aura Mind',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(rawSound),
        color: const Color(0xFF06B6D4),
      );
      const ios = DarwinNotificationDetails(presentSound: true);
      await _notifications.show(
        id,
        title,
        body,
        NotificationDetails(android: android, iOS: ios),
        payload: payload,
      );
    } catch (_) {
      await showNotification(
        title: title,
        body: body,
        payload: payload,
        id: id,
      );
    }
  }

  static Future<void> showRoutineNotification({
    required String deviceName,
    required String action,
  }) async {
    await showNotification(
      id: 102,
      title: 'Rotina executada',
      body: '$deviceName: $action',
      payload: 'routine:$deviceName',
    );
  }

  static Future<void> showDeviceStatusNotification({
    required String deviceName,
    required String status,
  }) async {
    await showNotification(
      id: 103,
      title: 'Status do dispositivo',
      body: '$deviceName: $status',
      payload: 'device:$deviceName',
    );
  }

  static String _rawSoundForTone(String tone, {required String fallback}) {
    return switch (tone) {
      'Radar' => 'alarm_digital',
      'Cristal' => 'crystal_bell',
      'Aurora' => 'soft_piano',
      'Pulso' => 'digital_pulse',
      'Chime' => 'chime',
      'Soft Bell' => 'soft_bell',
      'Deep Focus' => 'deep_focus',
      'Chuva' => 'rain',
      'Oceano' => 'ocean',
      'Emergencia' => 'emergency_soft',
      _ => fallback,
    };
  }

  static void _initializeTimeZones() {
    if (_timeZonesInitialized) return;
    tzdata.initializeTimeZones();
    _timeZonesInitialized = true;
  }

  static int _scheduledId(String kind, String sourceId, int slot) {
    final raw = '$kind:$sourceId:$slot';
    var hash = 0;
    for (final unit in raw.codeUnits) {
      hash = ((hash * 31) + unit) & 0x3fffffff;
    }
    return 200000 + hash;
  }

  static DateTime _nextWeekdayOccurrence(String time, String dayLabel) {
    final now = DateTime.now();
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 8;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final targetWeekday = _weekdayFromLabel(dayLabel) ?? now.weekday;
    var candidate = DateTime(now.year, now.month, now.day, hour, minute);
    for (var i = 0; i < 8; i++) {
      if (candidate.weekday == targetWeekday && candidate.isAfter(now)) {
        return candidate;
      }
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  static int? _weekdayFromLabel(String label) {
    final clean = label
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .trim();
    return switch (clean) {
      'seg' || 'segunda' => DateTime.monday,
      'ter' || 'terça' || 'terca' => DateTime.tuesday,
      'qua' || 'quarta' => DateTime.wednesday,
      'qui' || 'quinta' => DateTime.thursday,
      'sex' || 'sexta' => DateTime.friday,
      'sab' || 'sábado' || 'sabado' => DateTime.saturday,
      'dom' || 'domingo' => DateTime.sunday,
      _ => null,
    };
  }
}
