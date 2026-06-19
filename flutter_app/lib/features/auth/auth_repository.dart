import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/aura_auth_service.dart';

class AuthRepository {
  SupabaseClient? get _client => AuraAuthService.client;

  User? get currentUser => _client?.auth.currentUser;

  String? get currentUserId => currentUser?.id;

  Future<String?> currentAccessToken() async {
    final session = _client?.auth.currentSession;
    return session?.accessToken;
  }

  Future<void> signOut() async {
    await _client?.auth.signOut();
  }
}
