import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cross_file/cross_file.dart';

import '../../services/aura_auth_service.dart';

class UserProfileData {
  const UserProfileData({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl = '',
    this.avatarPath = '',
  });

  final String id;
  final String email;
  final String name;
  final String avatarUrl;
  final String avatarPath;
}

class UploadedPhoto {
  const UploadedPhoto({required this.url, required this.path});

  final String url;
  final String path;
}

class UserRepository {
  SupabaseClient? get _client => AuraAuthService.client;
  static const String profilePhotosBucket = 'aura-profile-photos';

  Future<UserProfileData?> loadProfile(User user) async {
    final supabase = _client;
    if (supabase == null) return null;

    final fallbackEmail = user.email ?? '';
    final fallbackName = AuraAuthService.displayNameFromUser(user);

    Map<String, dynamic>? response;
    try {
      response = await supabase
          .from('profiles')
          .select('id, email, name, full_name, avatar_url, avatar_path')
          .eq('id', user.id)
          .maybeSingle();
    } catch (_) {
      response = await supabase
          .from('profiles')
          .select('id, email, name, full_name, avatar_url')
          .eq('id', user.id)
          .maybeSingle();
    }

    if (response == null) {
      final createdName = fallbackName.isEmpty ? 'Novo usuario' : fallbackName;
      await supabase.from('profiles').upsert({
        'id': user.id,
        'email': fallbackEmail,
        'name': createdName,
      });
      return UserProfileData(
        id: user.id,
        email: fallbackEmail,
        name: createdName,
      );
    }

    final data = response;
    final profileName = (data['full_name'] ?? data['name'] ?? '')
        .toString()
        .trim();
    final avatarPath = (data['avatar_path'] ?? '').toString().trim();
    var avatarUrl = (data['avatar_url'] ?? '').toString();
    if (avatarPath.isNotEmpty) {
      try {
        avatarUrl = await supabase.storage
            .from(profilePhotosBucket)
            .createSignedUrl(avatarPath, 60 * 60 * 24 * 365);
      } catch (_) {}
    }
    return UserProfileData(
      id: user.id,
      email: (data['email'] ?? fallbackEmail).toString(),
      name: profileName.isEmpty
          ? (fallbackName.isEmpty ? 'Usuario' : fallbackName)
          : profileName,
      avatarUrl: avatarUrl,
      avatarPath: avatarPath,
    );
  }

  Future<UploadedPhoto?> uploadProfilePhoto({
    required String userId,
    required XFile file,
  }) async {
    final supabase = _client;
    if (supabase == null || userId.isEmpty) {
      return UploadedPhoto(url: file.path, path: '');
    }
    try {
      final extension = file.name.split('.').last.toLowerCase();
      final safeExtension = extension.isEmpty || extension.length > 5
          ? 'jpg'
          : extension;
      final path = '$userId/profile/avatar.$safeExtension';
      final upload = await _uploadPhoto(path: path, file: file);
      if (upload == null) return UploadedPhoto(url: file.path, path: '');
      try {
        await supabase.from('profiles').upsert({
          'id': userId,
          'avatar_path': upload.path,
          'avatar_url': upload.url,
        });
      } catch (_) {
        await supabase.from('profiles').upsert({
          'id': userId,
          'avatar_url': upload.url,
        });
      }
      return upload;
    } catch (_) {
      return UploadedPhoto(url: file.path, path: '');
    }
  }

  Future<UploadedPhoto?> uploadGroupPhoto({
    required String ownerId,
    required String groupId,
    required XFile file,
  }) async {
    if (ownerId.isEmpty || groupId.isEmpty) return null;
    final extension = file.name.split('.').last.toLowerCase();
    final safeExtension = extension.isEmpty || extension.length > 5
        ? 'jpg'
        : extension;
    return _uploadPhoto(
      path: '$ownerId/groups/$groupId/avatar.$safeExtension',
      file: file,
    );
  }

  Future<UploadedPhoto?> uploadManagedPhoto({
    required String ownerId,
    required String targetId,
    required XFile file,
  }) async {
    final supabase = _client;
    if (supabase == null || ownerId.isEmpty || targetId.isEmpty) {
      return UploadedPhoto(url: file.path, path: '');
    }
    try {
      final extension = file.name.split('.').last.toLowerCase();
      final safeExtension = extension.isEmpty || extension.length > 5
          ? 'jpg'
          : extension;
      final upload = await _uploadPhoto(
        path: '$ownerId/managed/$targetId/avatar.$safeExtension',
        file: file,
      );
      return upload ?? UploadedPhoto(url: file.path, path: '');
    } catch (_) {
      return UploadedPhoto(url: file.path, path: '');
    }
  }

  Future<void> saveProfile({
    required String userId,
    required String name,
    required String email,
    String? avatarUrl,
    String? avatarPath,
  }) async {
    final supabase = _client;
    if (supabase == null || userId.isEmpty) return;
    final payload = <String, dynamic>{
      'id': userId,
      'name': name.trim(),
      'full_name': name.trim(),
      if (email.trim().isNotEmpty) 'email': email.trim(),
      if (avatarUrl?.trim().isNotEmpty == true) 'avatar_url': avatarUrl!.trim(),
      if (avatarPath?.trim().isNotEmpty == true)
        'avatar_path': avatarPath!.trim(),
    };
    try {
      await supabase.from('profiles').upsert(payload);
    } catch (_) {
      try {
        final fallback = Map<String, dynamic>.from(payload)
          ..remove('avatar_path');
        await supabase.from('profiles').upsert(fallback);
      } catch (_) {
        // Local profile state remains available when Supabase is offline.
      }
    }
  }

  String _contentTypeFor(String extension) {
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  Future<UploadedPhoto?> _uploadPhoto({
    required String path,
    required XFile file,
  }) async {
    final supabase = _client;
    if (supabase == null) return null;
    final extension = path.split('.').last.toLowerCase();
    final bytes = await file.readAsBytes();
    await supabase.storage
        .from(profilePhotosBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: _contentTypeFor(extension),
          ),
        );
    final signedUrl = await supabase.storage
        .from(profilePhotosBucket)
        .createSignedUrl(path, 60 * 60 * 24 * 365);
    return UploadedPhoto(url: signedUrl, path: path);
  }

  Future<String> createSignedPhotoUrl(String path) async {
    final cleanPath = path.trim();
    final supabase = _client;
    if (supabase == null || cleanPath.isEmpty) return '';
    try {
      return await supabase.storage
          .from(profilePhotosBucket)
          .createSignedUrl(cleanPath, 60 * 60 * 24 * 7);
    } catch (_) {
      return '';
    }
  }
}
