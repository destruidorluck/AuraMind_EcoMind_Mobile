import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;

import '../../core/storage/local_storage.dart';
import '../../models/aura_models.dart';
import '../../services/aura_auth_service.dart';
import '../shared/model_codecs.dart';

class DevicesRepository {
  DevicesRepository(this._storage);

  final LocalStorage _storage;

  SupabaseClient? get _client => AuraAuthService.client;

  static const String _localKey = 'devices';

  Future<List<AuraDevice>> load(
    String userId, {
    List<String> groupIds = const [],
  }) async {
    final local = _storage
        .getList(userId, _localKey)
        .map(ModelCodecs.deviceFromJson)
        .toList();
    final supabase = _client;
    if (supabase == null) return local;

    try {
      final response = await supabase
          .from('devices')
          .select()
          .eq('user_id', userId)
          .order('room', ascending: true);
      final rows = response.whereType<Map>().map((item) {
        return item.cast<String, dynamic>();
      }).toList();
      for (final groupId in groupIds.where((id) => id.trim().isNotEmpty)) {
        final groupResponse = await supabase
            .from('devices')
            .select()
            .eq('group_id', groupId.trim())
            .order('room', ascending: true);
        rows.addAll(
          groupResponse.whereType<Map>().map((item) {
            return item.cast<String, dynamic>();
          }),
        );
      }
      final seen = <String>{};
      final remote = rows.map((row) {
        final payload = row['payload'];
        if (payload is Map) {
          return ModelCodecs.deviceFromJson({
            ...row,
            ...payload.cast<String, dynamic>(),
          });
        }
        return ModelCodecs.deviceFromJson(row);
      }).where((device) => seen.add(device.id)).toList();
      if (remote.isEmpty && local.isNotEmpty) return local;
      await save(userId, remote, syncRemote: false);
      return remote;
    } catch (_) {
      return local;
    }
  }

  Future<void> save(
    String userId,
    List<AuraDevice> devices, {
    bool syncRemote = true,
  }) async {
    final payload = devices.map(ModelCodecs.deviceToJson).toList();
    await _storage.saveList(userId, _localKey, payload);
    if (!syncRemote) return;
    final supabase = _client;
    if (supabase == null) return;

    try {
      if (devices.isEmpty) return;
      await supabase.from('devices').upsert(
            devices.map((device) {
              final json = ModelCodecs.deviceToJson(device);
              return {
                'id': device.id,
                'user_id': userId,
                'name': device.name,
                'room': device.room,
                'type': device.type.name,
                'status': device.status,
                'active': device.active,
                'connections': device.connections.map((item) => item.name).toList(),
                'manufacturer': device.manufacturer,
                'model': device.model,
                if (device.groupId.trim().isNotEmpty) 'group_id': device.groupId,
                'payload': json,
                'updated_at': DateTime.now().toIso8601String(),
              };
            }).toList(),
          );
    } catch (error) {
      throw Exception('Falha ao sincronizar dispositivos: $error');
    }
  }

  Future<void> deleteRemote(String userId, String id) async {
    final supabase = _client;
    if (supabase == null || userId.isEmpty || id.isEmpty) return;
    try {
      await supabase.from('devices').delete().eq('user_id', userId).eq('id', id);
    } catch (error) {
      throw Exception('Falha ao remover dispositivo remoto: $error');
    }
  }

  Future<void> pushStatus(String userId, AuraDevice device) async {
    final supabase = _client;
    if (supabase == null || userId.isEmpty) return;
    try {
      await supabase.from('devices').upsert(
        {
          'id': device.id,
          'user_id': userId,
          'name': device.name,
          'room': device.room,
          'type': device.type.name,
          'status': device.status,
          'active': device.active,
          'connections': device.connections.map((item) => item.name).toList(),
          if (device.groupId.trim().isNotEmpty) 'group_id': device.groupId,
          'payload': ModelCodecs.deviceToJson(device),
          'last_seen': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (_) {
      // Best effort only.
    }
  }
}
