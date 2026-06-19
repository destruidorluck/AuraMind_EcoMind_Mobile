import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;

import '../../core/storage/local_storage.dart';
import '../../models/aura_models.dart';
import '../../services/aura_auth_service.dart';
import '../shared/model_codecs.dart';

class CommunicationRepository {
  CommunicationRepository(this._storage);

  final LocalStorage _storage;

  SupabaseClient? get _client => AuraAuthService.client;

  String _messagesKey({
    required String contactId,
    required String groupId,
  }) {
    final scope = groupId.trim().isNotEmpty ? 'group:$groupId' : 'contact:$contactId';
    return 'messages:$scope';
  }

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<List<AuraMessage>> loadMessages(
    String userId, {
    String contactId = '',
    String groupId = '',
  }) async {
    final key = _messagesKey(contactId: contactId, groupId: groupId);
    final local = _storage
        .getList(userId, key)
        .map(ModelCodecs.messageFromJson)
        .toList();
    final supabase = _client;
    if (supabase == null || userId.isEmpty) return local;

    try {
      dynamic query = supabase
          .from('aura_messages')
          .select()
          .eq('user_id', userId);
      if (groupId.trim().isNotEmpty) {
        query = query.eq('group_id', groupId.trim());
      } else {
        query = query.eq('contact_id', contactId.trim());
      }
      final response = await query.order('created_at', ascending: true);
      final remote = response
          .whereType<Map>()
          .map((row) => ModelCodecs.messageFromJson(row.cast<String, dynamic>()))
          .toList();
      if (remote.isEmpty && local.isNotEmpty) return local;
      await _storage.saveList(
        userId,
        key,
        remote.map(ModelCodecs.messageToJson).toList(),
      );
      return remote;
    } catch (_) {
      return local;
    }
  }

  Future<AuraMessage> sendMessage(
    String userId, {
    required String body,
    String contactId = '',
    String groupId = '',
    String direction = 'outgoing',
    Map<String, dynamic> payload = const <String, dynamic>{},
  }) async {
    final message = AuraMessage(
      id: newId(),
      userId: userId,
      contactId: contactId.trim(),
      groupId: groupId.trim(),
      direction: direction,
      body: body.trim(),
      createdAt: DateTime.now(),
    );
    final key = _messagesKey(contactId: message.contactId, groupId: message.groupId);
    final localRows = _storage.getList(userId, key);
    localRows.add(ModelCodecs.messageToJson(message));
    await _storage.saveList(userId, key, localRows);

    final supabase = _client;
    if (supabase != null && userId.isNotEmpty) {
      try {
        final messagePayload = {
          ...ModelCodecs.messageToJson(message),
          ...payload,
        };
        await supabase.from('aura_messages').insert({
          'id': message.id,
          'user_id': userId,
          if (message.contactId.isNotEmpty) 'contact_id': message.contactId,
          if (message.groupId.isNotEmpty) 'group_id': message.groupId,
          'direction': message.direction,
          'body': message.body,
          'payload': messagePayload,
          'created_at': message.createdAt.toIso8601String(),
        });
      } catch (_) {}
    }
    return message;
  }

  Future<List<AuraCallSession>> loadCallSessions(String userId) async {
    final local = _storage
        .getList(userId, 'call_sessions')
        .map(ModelCodecs.callSessionFromJson)
        .toList();
    final supabase = _client;
    if (supabase == null || userId.isEmpty) return local;

    try {
      final response = await supabase
          .from('call_sessions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final remote = response
          .whereType<Map>()
          .map((row) => ModelCodecs.callSessionFromJson(row.cast<String, dynamic>()))
          .toList();
      if (remote.isEmpty && local.isNotEmpty) return local;
      await _storage.saveList(
        userId,
        'call_sessions',
        remote.map(ModelCodecs.callSessionToJson).toList(),
      );
      return remote;
    } catch (_) {
      return local;
    }
  }

  Future<AuraCallSession> startCallSession(
    String userId, {
    String contactId = '',
    String groupId = '',
  }) async {
    final session = AuraCallSession(
      id: newId(),
      userId: userId,
      contactId: contactId.trim(),
      groupId: groupId.trim(),
      status: 'ringing',
      createdAt: DateTime.now(),
    );
    final rows = _storage.getList(userId, 'call_sessions');
    rows.insert(0, ModelCodecs.callSessionToJson(session));
    await _storage.saveList(userId, 'call_sessions', rows);

    final supabase = _client;
    if (supabase != null && userId.isNotEmpty) {
      try {
        final payload = ModelCodecs.callSessionToJson(session);
        await supabase.from('call_sessions').insert({
          'id': session.id,
          'user_id': userId,
          if (session.contactId.isNotEmpty) 'contact_id': session.contactId,
          if (session.groupId.isNotEmpty) 'group_id': session.groupId,
          'status': session.status,
          'payload': payload,
          'created_at': session.createdAt.toIso8601String(),
        });
      } catch (_) {}
    }
    return session;
  }

  Future<void> endCallSession(String userId, AuraCallSession session) async {
    session.status = 'ended';
    session.endedAt = DateTime.now();
    final rows = _storage.getList(userId, 'call_sessions');
    final nextRows = rows.map((row) {
      if ((row['id'] ?? '').toString() != session.id) return row;
      return ModelCodecs.callSessionToJson(session);
    }).toList();
    await _storage.saveList(userId, 'call_sessions', nextRows);

    final supabase = _client;
    if (supabase == null || userId.isEmpty) return;
    try {
      await supabase.from('call_sessions').update({
        'status': session.status,
        'ended_at': session.endedAt?.toIso8601String(),
        'payload': ModelCodecs.callSessionToJson(session),
      }).eq('id', session.id).eq('user_id', userId);
    } catch (_) {}
  }
}
