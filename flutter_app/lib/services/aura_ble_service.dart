import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../models/aura_models.dart';

class AuraBleService {
  static const int writePayloadLimit = 20;
  static const int _framedChunkSize = 10;
  static const List<String> targetNames = [
    'AuraMind-EcoMind',
    'AuraMind C6',
    'ECO MIND',
    'EcoMind',
  ];
  static final Guid serviceGuid = Guid('6E400001-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Guid rxGuid = Guid('6E400002-B5A3-F393-E0A9-E50E24DCCA9E');
  static final Guid txGuid = Guid('6E400003-B5A3-F393-E0A9-E50E24DCCA9E');

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _rxCharacteristic;
  BluetoothCharacteristic? _txCharacteristic;
  StreamSubscription<List<int>>? _txSubscription;
  final StreamController<String> _messages =
      StreamController<String>.broadcast();
  String _txJsonBuffer = '';

  Stream<String> get messages => _messages.stream;
  bool get isReady =>
      _connectedDevice?.isConnected == true &&
      _rxCharacteristic != null &&
      _txCharacteristic != null;
  int get mtu => _connectedDevice?.mtuNow ?? 23;

  static List<String> encodeCommandForEcoMind(Map<String, Object?> command) {
    final short = _shortCommandFor(command);
    if (short != null) return [short];

    final payload = jsonEncode(command);
    if (utf8.encode(payload).length <= writePayloadLimit) {
      return [payload];
    }

    final encoded = base64Encode(utf8.encode(payload));
    final total = (encoded.length / _framedChunkSize).ceil();
    return [
      for (var index = 0; index < total; index++)
        '#${index + 1}/$total:${encoded.substring(index * _framedChunkSize, ((index + 1) * _framedChunkSize).clamp(0, encoded.length).toInt())}',
    ];
  }

  static bool matchesEcoMindName(String name, {bool advertisesUart = false}) {
    if (advertisesUart) return true;
    final lowerName = name.toLowerCase();
    final normalized = lowerName.replaceAll(RegExp(r'[^a-z0-9]+'), '');
    return targetNames.any((target) {
          final normalizedTarget = target.toLowerCase().replaceAll(
            RegExp(r'[^a-z0-9]+'),
            '',
          );
          return normalized == normalizedTarget ||
              normalized.contains(normalizedTarget);
        }) ||
        lowerName.contains('aura') ||
        lowerName.contains('esp') ||
        lowerName.contains('c6');
  }

  Future<List<AuraNetworkItem>> scanEsp32Devices() async {
    final discovered = <String, AuraNetworkItem>{};
    final sub = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final id = result.device.remoteId.toString();
        final name = _displayName(result);
        final advertisesUart = result.advertisementData.serviceUuids.contains(
          serviceGuid,
        );
        if (!matchesEcoMindName(name, advertisesUart: advertisesUart)) {
          continue;
        }
        discovered[id] = AuraNetworkItem(
          id: id,
          name: name.isEmpty ? 'EcoMind' : name,
          type: 'Bluetooth',
          signal: '${result.rssi} dBm',
          available: true,
        );
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));
      await Future<void>.delayed(const Duration(seconds: 6));
      await FlutterBluePlus.stopScan();
    } finally {
      await sub.cancel();
    }

    return discovered.values.toList();
  }

  Future<bool> connect(String remoteId) async {
    await disconnect();
    final target = BluetoothDevice.fromId(remoteId);
    await target.connect(
      timeout: const Duration(seconds: 12),
      autoConnect: false,
      mtu: 185,
    );
    final services = await target.discoverServices();
    BluetoothCharacteristic? rxChar;
    BluetoothCharacteristic? txChar;

    for (final service in services) {
      if (service.uuid != serviceGuid) continue;
      for (final characteristic in service.characteristics) {
        if (characteristic.uuid == rxGuid) {
          rxChar = characteristic;
        } else if (characteristic.uuid == txGuid) {
          txChar = characteristic;
        }
      }
    }

    if (rxChar == null || txChar == null) {
      await target.disconnect();
      return false;
    }

    _connectedDevice = target;
    _rxCharacteristic = rxChar;
    _txCharacteristic = txChar;
    _txSubscription = txChar.onValueReceived.listen((data) {
      final text = utf8.decode(data, allowMalformed: true).trim();
      if (text.isNotEmpty) _handleTxText(text);
    });
    await txChar.setNotifyValue(true);
    _emit('BLE connected over Nordic UART. MTU: $mtu');
    return true;
  }

  Future<String> provisionWifi({
    required String ssid,
    required String password,
  }) async {
    if (!isReady) return 'not_connected';
    await sendJson({'cmd': 'wifi_connect', 'ssid': ssid, 'password': password});
    return 'sent';
  }

  Future<String> sendJson(Map<String, Object?> command) async {
    final rxChar = _rxCharacteristic;
    if (rxChar == null || _connectedDevice?.isConnected != true) {
      return 'not_connected';
    }

    final payload = jsonEncode(command);
    final frames = encodeCommandForEcoMind(command);
    if (frames.any((frame) => utf8.encode(frame).length > writePayloadLimit)) {
      throw StateError('payload_too_large_for_ble_frame');
    }

    if (frames.length == 1 && frames.single == payload) {
      _emit('APP -> ESP json $payload');
    } else if (frames.length == 1) {
      _emit('APP -> ESP short ${frames.single}');
    } else {
      _emit('APP -> ESP framed ${frames.length} frames $payload');
    }

    for (final frame in frames) {
      await rxChar.write(utf8.encode(frame), withoutResponse: false);
      if (frames.length > 1) {
        await Future<void>.delayed(const Duration(milliseconds: 25));
      }
    }
    return frames.length == 1 ? frames.single : 'framed:${frames.length}';
  }

  Future<void> disconnect() async {
    await _txSubscription?.cancel();
    _txSubscription = null;
    if (_txCharacteristic?.isNotifying == true) {
      try {
        await _txCharacteristic?.setNotifyValue(false);
      } catch (_) {
        // The device may already be gone.
      }
    }
    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _rxCharacteristic = null;
    _txCharacteristic = null;
    _txJsonBuffer = '';
  }

  Future<void> dispose() async {
    await disconnect();
    await _messages.close();
  }

  String _displayName(ScanResult result) {
    final advName = result.advertisementData.advName.trim();
    if (advName.isNotEmpty) return advName;
    final platformName = result.device.platformName.trim();
    if (platformName.isNotEmpty) return platformName;
    final deviceAdvName = result.device.advName.trim();
    if (deviceAdvName.isNotEmpty) return deviceAdvName;
    return '';
  }

  void _emit(String message) {
    if (!_messages.isClosed) _messages.add(message);
  }

  static String? _shortCommandFor(Map<String, Object?> command) {
    final cmd = command['cmd']?.toString().trim().toLowerCase();
    return switch (cmd) {
      'state' => 'S:${command['state'] ?? 'idle'}',
      'led' => 'L:${command['color'] ?? 'idle'}',
      'backend_health' => 'BH',
      'brightness' => 'B:${command['value'] ?? 35}',
      _ => null,
    };
  }

  void _handleTxText(String text) {
    if (_txJsonBuffer.isNotEmpty || text.startsWith('{')) {
      _txJsonBuffer += text;
      try {
        jsonDecode(_txJsonBuffer);
        _emit('ESP -> APP $_txJsonBuffer');
        _txJsonBuffer = '';
      } catch (_) {
        if (_txJsonBuffer.length > 8192) {
          _emit('ESP -> APP $_txJsonBuffer');
          _txJsonBuffer = '';
        }
      }
      return;
    }
    _emit('ESP -> APP $text');
  }
}
