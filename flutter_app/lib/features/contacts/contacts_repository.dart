import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;

import '../../core/storage/local_storage.dart';
import '../../models/aura_models.dart';
import '../../services/aura_auth_service.dart';
import '../shared/model_codecs.dart';

class ContactsRepository {
  ContactsRepository(this._storage);

  final LocalStorage _storage;

  SupabaseClient? get _client => AuraAuthService.client;

  static const String _localKey = 'contacts';

  Future<List<AuraContact>> load(String userId) async {
    final local = _storage
        .getList(userId, _localKey)
        .map(ModelCodecs.contactFromJson)
        .toList();

    final supabase = _client;
    if (supabase == null) return local;

    try {
      final response = await supabase
          .from('contacts')
          .select()
          .eq('user_id', userId)
          .order('name', ascending: true);
      final remote = response.whereType<Map>().map((item) {
        final row = item.cast<String, dynamic>();
        final payload = row['payload'];
        if (payload is Map) {
          return ModelCodecs.contactFromJson(payload.cast<String, dynamic>());
        }
        return ModelCodecs.contactFromJson(row);
      }).toList();
      if (remote.isEmpty && local.isNotEmpty) return local;
      await save(userId, remote, syncRemote: false);
      return remote;
    } catch (_) {
      return local;
    }
  }

  Future<void> save(
    String userId,
    List<AuraContact> contacts, {
    bool syncRemote = true,
  }) async {
    final deduped = deduplicate(contacts);
    await _storage.saveList(
      userId,
      _localKey,
      deduped.map(ModelCodecs.contactToJson).toList(),
    );
    if (!syncRemote) return;
    final supabase = _client;
    if (supabase == null) return;

    try {
      if (deduped.isEmpty) return;
      await supabase.from('contacts').upsert(
            deduped.map((contact) {
              final payload = ModelCodecs.contactToJson(contact);
              return {
                'id': contact.id,
                'user_id': userId,
                'name': contact.name,
                'phone': normalizePhone(contact.phone),
                'type': contact.type,
                'time': contact.time,
                if (contact.imageAsset?.trim().isNotEmpty == true)
                  'avatar_url': contact.imageAsset,
                'payload': payload,
                'updated_at': DateTime.now().toIso8601String(),
              };
            }).toList(),
          );
    } catch (_) {
      // Keep local state when backend is offline.
    }
  }

  Future<void> deleteRemote(String userId, String id) async {
    final supabase = _client;
    if (supabase == null || userId.isEmpty || id.isEmpty) return;
    try {
      await supabase.from('contacts').delete().eq('user_id', userId).eq('id', id);
    } catch (_) {}
  }

  List<AuraContact> deduplicate(List<AuraContact> values) {
    final seen = <String>{};
    final result = <AuraContact>[];
    for (final contact in values) {
      final normalized = normalizePhone(contact.phone);
      final key = normalized.isEmpty ? contact.id : normalized;
      if (seen.contains(key)) continue;
      seen.add(key);
      result.add(
        AuraContact(
          id: contact.id,
          name: contact.name.trim(),
          phone: normalized.isEmpty ? contact.phone.trim() : normalized,
          type: contact.type,
          time: contact.time,
        ),
      );
    }
    return result;
  }

  String normalizePhone(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+')) return digits;
    if (digits.startsWith('55')) return '+$digits';
    if (digits.length >= 10) return '+55$digits';
    return digits;
  }
}
