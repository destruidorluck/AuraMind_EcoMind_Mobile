import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';

enum AuraAuthProvider { apple, microsoft, google }

class AuraAuthService {
  static const String _url = AppConfig.supabaseUrl;
  static const String _anonKey = AppConfig.supabaseAnonKey;
  static const String _webRedirectUrl = AppConfig.webRedirectUrl;
  static bool _initialized = false;

  static bool get isConfigured => _url.isNotEmpty && _anonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured || _initialized) return;
    await Supabase.initialize(url: _url, anonKey: _anonKey);
    _initialized = true;
  }

  static SupabaseClient? get client {
    if (!isConfigured || !_initialized) return null;
    return Supabase.instance.client;
  }

  static String displayNameFromUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final candidates = [
      metadata['full_name'],
      metadata['name'],
      metadata['display_name'],
      metadata['preferred_username'],
    ];
    for (final candidate in candidates) {
      final value = candidate?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    final email = user.email?.trim() ?? '';
    if (email.contains('@')) return email.split('@').first;
    return '';
  }

  static Future<String> signInWithEmail(String email, String password) async {
    final supabase = client;
    if (supabase == null) {
      return 'Modo demo: Supabase não configurado.';
    }

    await supabase.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
    return 'Login realizado com Supabase.';
  }

  static Future<String> recoverPassword(String email) async {
    final supabase = client;
    if (supabase == null) {
      return 'Configure SUPABASE_URL e SUPABASE_ANON_KEY para recuperar senha.';
    }

    await supabase.auth.resetPasswordForEmail(
      email.trim().toLowerCase(),
      redirectTo: kIsWeb ? _webRedirectUrl : 'auramind://reset-password',
    );
    return 'Link de recuperação enviado para seu e-mail.';
  }

  static Future<String> signInWithProvider(AuraAuthProvider provider) async {
    final supabase = client;
    if (supabase == null) {
      return 'Configure Supabase para habilitar login social.';
    }

    final oauthProvider = switch (provider) {
      AuraAuthProvider.apple => OAuthProvider.apple,
      AuraAuthProvider.microsoft => OAuthProvider.azure,
      AuraAuthProvider.google => OAuthProvider.google,
    };

    await supabase.auth.signInWithOAuth(
      oauthProvider,
      redirectTo: kIsWeb ? _webRedirectUrl : 'auramind://login-callback',
    );
    return 'Redirecionando para autenticação.';
  }
}
