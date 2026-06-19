import 'dart:convert';
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as contacts;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wifi_scan/wifi_scan.dart';

import '../models/aura_models.dart';

class AuraWeatherResult {
  const AuraWeatherResult({
    required this.temperature,
    required this.location,
    this.condition = 'Tempo local',
    this.precipitationMm = 0,
    this.humidity = 0,
    this.windSpeedKmh = 0,
    this.latitude = 0,
    this.longitude = 0,
  });

  final int temperature;
  final String location;
  final String condition;
  final double precipitationMm;
  final int humidity;
  final double windSpeedKmh;
  final double latitude;
  final double longitude;
}

class AuraNativeMessage {
  const AuraNativeMessage({
    required this.id,
    required this.address,
    required this.body,
    required this.direction,
    required this.createdAt,
  });

  final String id;
  final String address;
  final String body;
  final String direction;
  final DateTime createdAt;
}

class AuraNativeCallLog {
  const AuraNativeCallLog({
    required this.id,
    required this.number,
    required this.type,
    required this.createdAt,
    required this.durationSeconds,
  });

  final String id;
  final String number;
  final String type;
  final DateTime createdAt;
  final int durationSeconds;
}

class AuraPlatformService {
  static AudioPlayer? _tonePlayer;
  static AudioPlayer? _voicePlayer;
  static Timer? _toneStopTimer;
  static const MethodChannel _nativeChannel = MethodChannel(
    'auramind/native_telephony',
  );

  static AudioPlayer get _activeTonePlayer => _tonePlayer ??= AudioPlayer();

  static AudioPlayer get _activeVoicePlayer => _voicePlayer ??= AudioPlayer();

  static Future<Map<String, bool>> requestCorePermissions() async {
    if (kIsWeb) {
      return const {
        'microphone': false,
        'camera': false,
        'contacts': false,
        'notifications': false,
        'location': false,
        'bluetooth': false,
        'wifi': false,
      };
    }

    final location = await Permission.locationWhenInUse.request();
    final microphone = await Permission.microphone.request();
    final camera = await Permission.camera.request();
    final contactsStatus = await contacts.FlutterContacts.permissions.request(
      contacts.PermissionType.read,
    );
    final notifications = await Permission.notification.request();
    PermissionStatus? bluetooth;
    PermissionStatus? wifi;

    if (defaultTargetPlatform == TargetPlatform.android) {
      bluetooth = await Permission.bluetoothScan.request();
      await Permission.bluetoothConnect.request();
      wifi = await Permission.nearbyWifiDevices.request();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      bluetooth = await Permission.bluetooth.request();
    }

    return {
      'microphone': microphone.isGranted,
      'camera': camera.isGranted,
      'contacts':
          contactsStatus == contacts.PermissionStatus.granted ||
          contactsStatus == contacts.PermissionStatus.limited,
      'notifications': notifications.isGranted,
      'location': location.isGranted,
      'bluetooth': bluetooth?.isGranted ?? false,
      'wifi': wifi?.isGranted ?? false,
    };
  }

  static Future<Map<String, bool>> readPermissionStatus() async {
    if (kIsWeb) {
      return const {
        'microphone': false,
        'camera': false,
        'contacts': false,
        'notifications': false,
        'location': false,
        'bluetooth': false,
        'wifi': false,
        'callPhone': false,
        'sms': false,
        'callLog': false,
      };
    }

    Future<bool> granted(Future<PermissionStatus> status) async {
      try {
        final value = await status;
        return value.isGranted || value.isLimited;
      } catch (_) {
        return false;
      }
    }

    var contactsGranted = false;
    try {
      final status = await contacts.FlutterContacts.permissions.check(
        contacts.PermissionType.read,
      );
      contactsGranted =
          status == contacts.PermissionStatus.granted ||
          status == contacts.PermissionStatus.limited;
    } catch (_) {}

    final telephony = defaultTargetPlatform == TargetPlatform.android
        ? await _readTelephonyPermissionStatus()
        : const <String, bool>{};

    return {
      'microphone': await granted(Permission.microphone.status),
      'camera': await granted(Permission.camera.status),
      'contacts': contactsGranted,
      'notifications': await granted(Permission.notification.status),
      'location': await granted(Permission.locationWhenInUse.status),
      'bluetooth': await granted(
        defaultTargetPlatform == TargetPlatform.android
            ? Permission.bluetoothConnect.status
            : Permission.bluetooth.status,
      ),
      'wifi': await granted(
        defaultTargetPlatform == TargetPlatform.android
            ? Permission.nearbyWifiDevices.status
            : Permission.locationWhenInUse.status,
      ),
      'callPhone': telephony['callPhone'] ?? false,
      'sms': telephony['sms'] ?? false,
      'callLog': telephony['callLog'] ?? false,
    };
  }

  static Future<AuraWeatherResult?> readLocalWeather() async {
    try {
      final locationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition();
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': position.latitude.toStringAsFixed(4),
        'longitude': position.longitude.toStringAsFixed(4),
        'current':
            'temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m',
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>?;
      final temperature = (current?['temperature_2m'] as num?)?.round();
      if (temperature == null) return null;
      final location = await _reverseGeocode(
        position.latitude,
        position.longitude,
      );
      return AuraWeatherResult(
        temperature: temperature,
        location: location ?? (kIsWeb ? 'Local atual' : 'Perto de voce'),
        condition: _weatherCodeLabel(
          (current?['weather_code'] as num?)?.round(),
        ),
        precipitationMm: (current?['precipitation'] as num?)?.toDouble() ?? 0,
        humidity: (current?['relative_humidity_2m'] as num?)?.round() ?? 0,
        windSpeedKmh: (current?['wind_speed_10m'] as num?)?.toDouble() ?? 0,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<AuraWeatherResult?> readWeatherForCoordinates({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      if (latitude == 0 && longitude == 0) return null;
      final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
        'latitude': latitude.toStringAsFixed(4),
        'longitude': longitude.toStringAsFixed(4),
        'current':
            'temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m',
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>?;
      final temperature = (current?['temperature_2m'] as num?)?.round();
      if (temperature == null) return null;
      return AuraWeatherResult(
        temperature: temperature,
        location: locationName,
        condition: _weatherCodeLabel(
          (current?['weather_code'] as num?)?.round(),
        ),
        precipitationMm: (current?['precipitation'] as num?)?.toDouble() ?? 0,
        humidity: (current?['relative_humidity_2m'] as num?)?.round() ?? 0,
        windSpeedKmh: (current?['wind_speed_10m'] as num?)?.toDouble() ?? 0,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<List<AuraContact>> readDeviceContacts() async {
    try {
      if (kIsWeb) return const [];
      final status = await contacts.FlutterContacts.permissions.request(
        contacts.PermissionType.read,
      );
      if (status != contacts.PermissionStatus.granted &&
          status != contacts.PermissionStatus.limited) {
        return const [];
      }

      final deviceContacts = await contacts.FlutterContacts.getAll(
        properties: {
          contacts.ContactProperty.name,
          contacts.ContactProperty.phone,
        },
      );

      final imported = <AuraContact>[];
      for (final contact in deviceContacts) {
        final name = (contact.displayName ?? '').trim();
        if (name.isEmpty) continue;
        if (contact.phones.isEmpty) {
          imported.add(
            AuraContact(
              id:
                  contact.id ??
                  DateTime.now().microsecondsSinceEpoch.toString(),
              name: name,
              phone: '',
              time: 'Celular',
              type: 'Contato do celular',
            ),
          );
          continue;
        }
        for (var index = 0; index < contact.phones.length; index++) {
          final phone = contact.phones[index].number.trim();
          if (phone.isEmpty) continue;
          imported.add(
            AuraContact(
              id: '${contact.id ?? DateTime.now().microsecondsSinceEpoch}-$index',
              name: name,
              phone: phone,
              time: 'Celular',
              type: 'Contato do celular',
            ),
          );
        }
      }
      return imported;
    } catch (_) {
      return const [];
    }
  }

  static Future<String?> pickImageForAuraSearch() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      return image?.name;
    } catch (_) {
      return null;
    }
  }

  static Future<XFile?> pickProfileImage() async {
    try {
      return await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 86,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<bool> setAppBrightness(double value) async {
    try {
      await ScreenBrightness().setApplicationScreenBrightness(
        value.clamp(0, 1).toDouble(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> previewTone(String tone) async {
    _toneStopTimer?.cancel();
    final player = _activeTonePlayer;
    await player.stop();
    await player.setVolume(0.35);
    await _stopSystemRingtoneSafe();

    if (tone.startsWith('system:')) {
      final uri = tone.substring('system:'.length);
      try {
        await contacts.FlutterContacts.ringtones.play(uri);
        _toneStopTimer = Timer(
          const Duration(seconds: 2),
          _stopSystemRingtoneSafe,
        );
        return;
      } catch (_) {
        await SystemSound.play(SystemSoundType.alert);
        return;
      }
    }

    final asset = _toneAsset(tone);
    if (asset != null) {
      try {
        await player.play(AssetSource(asset));
        _toneStopTimer = Timer(const Duration(seconds: 2), () async {
          await player.stop();
        });
        return;
      } catch (_) {
        // Fall back to the platform alert.
      }
    }

    if (tone == 'Pulso') {
      await SystemSound.play(SystemSoundType.click);
      await Future<void>.delayed(const Duration(milliseconds: 140));
    }
    await SystemSound.play(SystemSoundType.alert);
  }

  static Future<void> playAlertTone(
    String tone, {
    int durationSeconds = 90,
    int volume = 100,
    bool vibrate = true,
  }) async {
    _toneStopTimer?.cancel();
    final player = _activeTonePlayer;
    await player.stop();
    await player.setVolume((volume.clamp(0, 100) / 100).toDouble());
    await _stopSystemRingtoneSafe();

    if (vibrate) {
      await vibrateAlert();
    }

    if (tone.startsWith('system:')) {
      final uri = tone.substring('system:'.length);
      try {
        await contacts.FlutterContacts.ringtones.play(uri);
        _toneStopTimer = Timer(
          Duration(seconds: durationSeconds.clamp(5, 300).toInt()),
          _stopSystemRingtoneSafe,
        );
        return;
      } catch (_) {}
    }

    final asset = _toneAsset(tone);
    if (asset != null) {
      try {
        await player.play(AssetSource(asset));
        _toneStopTimer = Timer(
          Duration(seconds: durationSeconds.clamp(5, 300).toInt()),
          () async => player.stop(),
        );
        return;
      } catch (_) {}
    }

    await SystemSound.play(SystemSoundType.alert);
  }

  static Future<void> stopTonePreview() async {
    _toneStopTimer?.cancel();
    await _tonePlayer?.stop();
    await _stopSystemRingtoneSafe();
  }

  static Future<void> playVoiceBytes(Uint8List bytes) async {
    if (bytes.isEmpty) return;
    try {
      final player = _activeVoicePlayer;
      await player.stop();
      await player.play(BytesSource(bytes));
    } catch (_) {
      // TTS is optional; text remains visible even if audio playback fails.
    }
  }

  static Future<Map<String, bool>> requestTelephonyPermissions() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const {
        'callPhone': false,
        'readPhoneState': false,
        'readCallLog': false,
        'sendSms': false,
        'readSms': false,
        'receiveSms': false,
      };
    }
    try {
      final result = await _nativeChannel.invokeMapMethod<String, bool>(
        'requestTelephonyPermissions',
      );
      return result ?? const {};
    } catch (_) {
      return const {};
    }
  }

  static Future<Map<String, bool>> _readTelephonyPermissionStatus() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return const {};
    }
    try {
      final result = await _nativeChannel.invokeMapMethod<String, bool>(
        'readTelephonyPermissionStatus',
      );
      if (result != null) {
        return {
          'callPhone': result['callPhone'] ?? false,
          'sms': result['sendSms'] == true || result['readSms'] == true,
          'callLog': result['readCallLog'] ?? false,
        };
      }
    } catch (_) {}

    try {
      final phone = await Permission.phone.status;
      final sms = await Permission.sms.status;
      return {
        'callPhone': phone.isGranted,
        'sms': sms.isGranted,
        'callLog': phone.isGranted,
      };
    } catch (_) {
      return const {};
    }
  }

  static Future<bool> placeCall(String rawNumber) async {
    final digits = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty) return false;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      return await _nativeChannel.invokeMethod<bool>('placeCall', {
            'number': digits,
          }) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> sendSms({
    required String rawNumber,
    required String body,
  }) async {
    final digits = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty || body.trim().isEmpty) return false;
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      return await _nativeChannel.invokeMethod<bool>('sendSms', {
            'number': digits,
            'body': body.trim(),
          }) ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<List<AuraNativeMessage>> loadSmsThread(String rawNumber) async {
    final digits = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty ||
        kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android) {
      return const [];
    }
    try {
      final rows = await _nativeChannel.invokeListMethod<Map<dynamic, dynamic>>(
        'loadSmsThread',
        {'number': digits},
      );
      return (rows ?? const [])
          .map(
            (row) => AuraNativeMessage(
              id: (row['id'] ?? '').toString(),
              address: (row['address'] ?? '').toString(),
              body: (row['body'] ?? '').toString(),
              direction: (row['direction'] ?? 'incoming').toString(),
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                row['date'] is num ? (row['date'] as num).round() : 0,
              ),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<List<AuraNativeCallLog>> loadCallLog(String rawNumber) async {
    final digits = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.isEmpty ||
        kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android) {
      return const [];
    }
    try {
      final rows = await _nativeChannel.invokeListMethod<Map<dynamic, dynamic>>(
        'loadCallLog',
        {'number': digits},
      );
      return (rows ?? const [])
          .map(
            (row) => AuraNativeCallLog(
              id: (row['id'] ?? '').toString(),
              number: (row['number'] ?? '').toString(),
              type: (row['type'] ?? '').toString(),
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                row['date'] is num ? (row['date'] as num).round() : 0,
              ),
              durationSeconds: row['duration'] is num
                  ? (row['duration'] as num).round()
                  : 0,
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> vibrateAlert() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await _nativeChannel.invokeMethod<void>('vibrateAlert');
        return;
      }
    } catch (_) {}
    await HapticFeedback.heavyImpact();
  }

  static Future<String?> pickSystemRingtone() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final uri = await contacts.FlutterContacts.ringtones.pick(
        contacts.RingtoneType.alarm,
      );
      return uri == null ? null : 'system:$uri';
    } catch (_) {
      return null;
    }
  }

  static Future<List<AuraNetworkItem>> scanWifiNetworks() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return [
        AuraNetworkItem(
          id: 'wifi-unavailable',
          name: 'Wi-Fi indisponivel nesta plataforma',
          type: 'Wi-Fi',
          signal: 'Use Android para listar redes proximas',
          available: false,
        ),
      ];
    }

    await Permission.locationWhenInUse.request();
    await Permission.nearbyWifiDevices.request();
    final canScan = await WiFiScan.instance.canStartScan();
    if (canScan != CanStartScan.yes) {
      return [
        AuraNetworkItem(
          id: 'wifi-denied',
          name: 'Nao foi possivel escanear Wi-Fi',
          type: 'Wi-Fi',
          signal: canScan.name,
          available: false,
        ),
      ];
    }

    await WiFiScan.instance.startScan();
    await Future<void>.delayed(const Duration(seconds: 2));
    final results = await WiFiScan.instance.getScannedResults();
    return results
        .where((item) => item.ssid.trim().isNotEmpty)
        .map(
          (item) => AuraNetworkItem(
            id: item.bssid.isNotEmpty ? item.bssid : item.ssid,
            name: item.ssid,
            type: 'Wi-Fi',
            signal: '${item.level} dBm',
            available: true,
          ),
        )
        .toList();
  }

  static Future<List<AuraNetworkItem>> scanBluetoothDevices() async {
    if (kIsWeb) {
      return [
        AuraNetworkItem(
          id: 'bt-unavailable',
          name: 'Bluetooth indisponivel no web',
          type: 'Bluetooth',
          signal: 'Use Android ou iOS',
          available: false,
        ),
      ];
    }

    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.locationWhenInUse.request();
    final found = <String, AuraNetworkItem>{};
    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final id = result.device.remoteId.toString();
        final name = result.device.platformName.trim().isEmpty
            ? 'Dispositivo Bluetooth'
            : result.device.platformName.trim();
        found[id] = AuraNetworkItem(
          id: id,
          name: name,
          type: 'Bluetooth',
          signal: '${result.rssi} dBm',
          available: true,
        );
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      await Future<void>.delayed(const Duration(seconds: 5));
      await FlutterBluePlus.stopScan();
    } catch (_) {
      // Keep fallback below.
    } finally {
      await subscription.cancel();
    }

    if (found.isEmpty) {
      return [
        AuraNetworkItem(
          id: 'bt-none',
          name: 'Nenhum Bluetooth encontrado',
          type: 'Bluetooth',
          signal: 'Tente aproximar o aparelho e buscar novamente',
          available: false,
        ),
      ];
    }
    return found.values.toList();
  }

  static Future<String?> _reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'jsonv2',
        'lat': latitude.toStringAsFixed(5),
        'lon': longitude.toStringAsFixed(5),
        'zoom': '10',
        'accept-language': 'pt-BR',
      });
      final response = await http
          .get(uri, headers: {'User-Agent': 'AuraMind/1.0'})
          .timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;
      final city =
          address?['city'] ??
          address?['town'] ??
          address?['village'] ??
          address?['municipality'] ??
          address?['state'];
      return city?.toString();
    } catch (_) {
      return null;
    }
  }

  static String _weatherCodeLabel(int? code) {
    return switch (code) {
      0 => 'Ceu limpo',
      1 || 2 => 'Parcialmente nublado',
      3 => 'Encoberto',
      45 || 48 => 'Neblina',
      51 || 53 || 55 => 'Garoa',
      56 || 57 => 'Garoa congelante',
      61 || 63 || 65 => 'Chuva',
      66 || 67 => 'Chuva congelante',
      71 || 73 || 75 => 'Neve',
      80 || 81 || 82 => 'Pancadas de chuva',
      95 || 96 || 99 => 'Trovoadas',
      _ => 'Tempo local',
    };
  }

  static String? _toneAsset(String tone) {
    return switch (tone) {
      'Radar' => 'sounds/alarm_digital.wav',
      'Cristal' => 'sounds/crystal_bell.wav',
      'Aurora' => 'sounds/soft_piano.wav',
      'Pulso' => 'sounds/digital_pulse.wav',
      'Chime' => 'sounds/chime.wav',
      'Soft Bell' => 'sounds/soft_bell.wav',
      'Deep Focus' => 'sounds/deep_focus.wav',
      'Chuva' => 'sounds/rain.wav',
      'Oceano' => 'sounds/ocean.wav',
      'Emergencia' => 'sounds/emergency_soft.wav',
      _ => null,
    };
  }

  static Future<void> _stopSystemRingtoneSafe() async {
    try {
      final dynamic ringtones = contacts.FlutterContacts.ringtones;
      await ringtones.stop();
    } catch (_) {
      // Some platforms/plugins may not expose stop.
    }
  }
}
