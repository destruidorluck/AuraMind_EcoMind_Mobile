import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;

import '../../core/config/app_config.dart';
import '../../core/storage/local_storage.dart';
import '../../models/aura_models.dart';
import '../../services/aura_auth_service.dart';
import '../shared/model_codecs.dart';

class GroupsRepository {
  GroupsRepository(this._storage);

  final LocalStorage _storage;
  static const String profilePhotosBucket = 'aura-profile-photos';

  SupabaseClient? get _client => AuraAuthService.client;

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<List<AuraGroup>> loadGroups(String userId) async {
    final local = _storage
        .getList(userId, 'groups')
        .map(ModelCodecs.groupFromJson)
        .toList();
    final supabase = _client;
    if (supabase == null || userId.isEmpty) return local;

    try {
      final response = await supabase
          .from('aura_groups')
          .select()
          .order('updated_at', ascending: false);
      final remote = response
          .whereType<Map>()
          .map((row) => ModelCodecs.groupFromJson(row.cast<String, dynamic>()))
          .toList();
      await _refreshSignedGroupImages(supabase, remote);
      if (remote.isEmpty && local.isNotEmpty) return local;
      await _storage.saveList(
        userId,
        'groups',
        remote.map(ModelCodecs.groupToJson).toList(),
      );
      return remote;
    } catch (_) {
      return local;
    }
  }

  Future<AuraGroup?> ensureDefaultGroup({
    required String userId,
    String name = 'Aura Mind',
  }) async {
    if (userId.isEmpty) return null;
    final existing = await loadGroups(userId);
    final owned = existing
        .where((group) => group.ownerId == userId)
        .firstOrNull;
    if (owned != null) return owned;

    final now = DateTime.now();
    final id = newId();
    final group = AuraGroup(
      id: id,
      ownerId: userId,
      name: name,
      inviteCode: _inviteCodeFor(id),
      memberIds: const [],
      createdAt: now,
      updatedAt: now,
    );
    await _storage.saveList(
      userId,
      'groups',
      [group, ...existing].map(ModelCodecs.groupToJson).toList(),
    );

    final supabase = _client;
    if (supabase != null) {
      try {
        await supabase.from('aura_groups').upsert({
          'id': group.id,
          'owner_id': userId,
          'name': group.name,
          'invite_code': group.inviteCode,
          'payload': ModelCodecs.groupToJson(group),
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        });
      } catch (_) {}
    }
    return group;
  }

  Future<AuraGroup> createGroup({
    String? id,
    required String userId,
    required String name,
    required List<AuraContact> members,
    String imageAsset = '',
    String imagePath = '',
  }) async {
    final now = DateTime.now();
    final groupId = id ?? newId();
    final group = AuraGroup(
      id: groupId,
      ownerId: userId,
      name: name.trim(),
      inviteCode: _inviteCodeFor(groupId),
      imageAsset: imageAsset.trim().isEmpty ? null : imageAsset.trim(),
      imagePath: imagePath.trim().isEmpty ? null : imagePath.trim(),
      memberIds: members.map((member) => member.id).toList(),
      createdAt: now,
      updatedAt: now,
    );

    final groups = _storage
        .getList(userId, 'groups')
        .map(ModelCodecs.groupFromJson)
        .where((item) => item.id != group.id)
        .toList()
      ..insert(0, group);
    await _storage.saveList(
      userId,
      'groups',
      groups.map(ModelCodecs.groupToJson).toList(),
    );

    final supabase = _client;
    if (supabase != null && userId.isNotEmpty) {
      try {
        final payload = ModelCodecs.groupToJson(group);
        final row = {
          'id': group.id,
          'owner_id': userId,
          'name': group.name,
          'invite_code': group.inviteCode,
          'payload': payload,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };
        try {
          await supabase.from('aura_groups').upsert({
            ...row,
            if (group.imageAsset?.trim().isNotEmpty == true)
              'image_url': group.imageAsset,
            if (group.imagePath?.trim().isNotEmpty == true)
              'image_path': group.imagePath,
          });
        } catch (_) {
          await supabase.from('aura_groups').upsert(row);
        }

        if (members.isNotEmpty) {
          await supabase.from('group_members').upsert(
                members.map((member) {
                  final email = _emailOrEmpty(member.phone);
                  final payload = {
                    ...ModelCodecs.contactToJson(member),
                    'group_id': group.id,
                    'invite_code': group.inviteCode,
                  };
                  return {
                    'id': '${group.id}:${member.id}',
                    'user_id': userId,
                    'group_id': group.id,
                    if (email.isNotEmpty) 'email': email,
                    'name': member.name,
                    'role': 'Membro',
                    'payload': payload,
                    'updated_at': now.toIso8601String(),
                  };
                }).toList(),
              );
        }
      } catch (_) {}
    }
    return group;
  }

  Future<void> createInvite({
    required String userId,
    required String email,
    required String role,
    required String inviteUrl,
    String groupId = '',
    String inviteCode = '',
    Map<String, dynamic> payload = const {},
  }) async {
    final supabase = _client;
    final normalizedEmail = email.trim().toLowerCase();
    if (supabase == null || userId.isEmpty || normalizedEmail.isEmpty) return;
    try {
      await supabase.from('member_invites').upsert({
        'id': '$userId:$normalizedEmail:${groupId.isEmpty ? 'account' : groupId}',
        'user_id': userId,
        if (groupId.isNotEmpty) 'group_id': groupId,
        'email': normalizedEmail,
        'role': role.trim().isEmpty ? 'Membro' : role.trim(),
        'invite_url': inviteUrl,
        'status': 'pending',
        'payload': {
          ...payload,
          if (inviteCode.isNotEmpty) 'invite_code': inviteCode,
        },
      });
    } catch (_) {}
  }

  Future<void> updateGroup({
    required String userId,
    required AuraGroup group,
  }) async {
    group.updatedAt = DateTime.now();
    final groups = _storage
        .getList(userId, 'groups')
        .map(ModelCodecs.groupFromJson)
        .where((item) => item.id != group.id)
        .toList()
      ..insert(0, group);
    await _storage.saveList(
      userId,
      'groups',
      groups.map(ModelCodecs.groupToJson).toList(),
    );
    final supabase = _client;
    if (supabase == null || userId.isEmpty) return;
    final payload = ModelCodecs.groupToJson(group);
    try {
      await supabase.from('aura_groups').update({
        'name': group.name,
        'image_url': group.imageAsset,
        'image_path': group.imagePath,
        'payload': payload,
        'updated_at': group.updatedAt!.toIso8601String(),
      }).eq('id', group.id).eq('owner_id', userId);
    } catch (_) {}
  }

  Future<void> deleteGroup({
    required String userId,
    required String groupId,
  }) async {
    final groups = _storage
        .getList(userId, 'groups')
        .where((row) => (row['id'] ?? '').toString() != groupId)
        .toList();
    await _storage.saveList(userId, 'groups', groups);
    final supabase = _client;
    if (supabase == null || userId.isEmpty || groupId.isEmpty) return;
    try {
      await supabase.from('aura_messages').delete().eq('group_id', groupId);
      await supabase.from('group_members').delete().eq('group_id', groupId);
      await supabase
          .from('aura_groups')
          .delete()
          .eq('id', groupId)
          .eq('owner_id', userId);
    } catch (_) {}
  }

  Future<void> acceptPendingInvites({
    required String userId,
    required String email,
    required String name,
  }) async {
    final supabase = _client;
    final normalizedEmail = email.trim().toLowerCase();
    if (supabase == null || userId.isEmpty || normalizedEmail.isEmpty) return;
    try {
      final response = await supabase
          .from('member_invites')
          .select()
          .eq('email', normalizedEmail)
          .eq('status', 'pending');

      for (final row in response.whereType<Map>()) {
        final invite = row.cast<String, dynamic>();
        final groupId = (invite['group_id'] ?? '').toString();
        if (groupId.isNotEmpty) {
          await supabase.from('group_members').upsert({
            'id': '$userId:$groupId',
            'user_id': userId,
            'group_id': groupId,
            'email': normalizedEmail,
            'name': name.trim().isEmpty ? normalizedEmail.split('@').first : name.trim(),
            'role': (invite['role'] ?? 'Membro').toString(),
            'payload': invite['payload'] is Map ? invite['payload'] : {},
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
        await supabase.from('member_invites').update({
          'status': 'accepted',
          'accepted_at': DateTime.now().toIso8601String(),
        }).eq('id', (invite['id'] ?? '').toString());
      }
    } catch (_) {}
  }

  String buildInviteUrl({
    required String inviteCode,
    required String email,
    String groupId = '',
  }) {
    return Uri(
      scheme: 'auramind',
      host: 'invite',
      queryParameters: {
        'code': inviteCode,
        if (groupId.isNotEmpty) 'group': groupId,
        'email': email.trim().toLowerCase(),
        'fallback': AppConfig.webRedirectUrl,
      },
    ).toString();
  }

  String _inviteCodeFor(String id) {
    final safe = id.padLeft(12, '0');
    return 'aura-${safe.substring(safe.length - 8)}';
  }

  String _emailOrEmpty(String value) {
    final trimmed = value.trim().toLowerCase();
    return trimmed.contains('@') ? trimmed : '';
  }

  Future<void> _refreshSignedGroupImages(
    SupabaseClient supabase,
    List<AuraGroup> groups,
  ) async {
    for (final group in groups) {
      final path = group.imagePath?.trim() ?? '';
      if (path.isEmpty) continue;
      try {
        group.imageAsset = await supabase.storage
            .from(profilePhotosBucket)
            .createSignedUrl(path, 60 * 60 * 24 * 7);
      } catch (_) {}
    }
  }
}
