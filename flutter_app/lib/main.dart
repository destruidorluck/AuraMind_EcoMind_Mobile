import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_root.dart';
import 'core/theme/aura_theme.dart';
import 'services/aura_auth_service.dart';
import 'services/aura_notification_service.dart';
import 'services/aura_storage_service.dart';
import 'state/aura_controller.dart';
import 'state/aura_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuraAuthService.initialize();
  await AuraStorageService.initialize();
  await AuraNotificationService.initialize();
  runApp(const AuraMindApp());
}

class AuraMindApp extends StatefulWidget {
  const AuraMindApp({super.key});

  @override
  State<AuraMindApp> createState() => _AuraMindAppState();
}

class _AuraMindAppState extends State<AuraMindApp> {
  late final AuraController _controller;
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<Uri>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AuraController(
      initialLanguage: AuraStorageService.getLanguage(),
    );
    _bindSupabaseAuth();
    unawaited(_bindDeepLinks());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initializeApp();
      _controller.bootstrapNativeState();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _deepLinkSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _bindDeepLinks() async {
    try {
      final appLinks = AppLinks();
      final initial = await appLinks.getInitialLink();
      if (initial != null) {
        await _controller.handleDeepLink(initial);
      }
      _deepLinkSubscription = appLinks.uriLinkStream.listen(
        (uri) => _controller.handleDeepLink(uri),
        onError: (_) {},
      );
    } catch (_) {}
  }

  void _bindSupabaseAuth() {
    final client = AuraAuthService.client;
    if (client == null) return;

    final currentUser = client.auth.currentUser;
    if (currentUser != null) {
      _controller.onAuthenticatedSession(
        userId: currentUser.id,
        email: currentUser.email ?? '',
        name: AuraAuthService.displayNameFromUser(currentUser),
      );
    }

    _authSubscription = client.auth.onAuthStateChange.listen(
      (state) {
        final user = state.session?.user;
        if (user == null) {
          _controller.logout(remote: false);
          return;
        }
        _controller.onAuthenticatedSession(
          userId: user.id,
          email: user.email ?? '',
          name: AuraAuthService.displayNameFromUser(user),
        );
      },
      onError: (Object error, StackTrace stackTrace) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final themeMode = switch (_controller.themeMode) {
          'light' => ThemeMode.light,
          'system' => ThemeMode.system,
          _ => ThemeMode.dark,
        };

        return AuraScope(
          controller: _controller,
          child: MaterialApp(
            title: 'Aura Mind',
            debugShowCheckedModeBanner: false,
            theme: auraLightTheme,
            darkTheme: auraDarkTheme,
            themeMode: themeMode,
            builder: (context, child) {
              return ScrollConfiguration(
                behavior: const _AuraScrollBehavior(),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: AppRoot(controller: _controller),
          ),
        );
      },
    );
  }
}

class _AuraScrollBehavior extends MaterialScrollBehavior {
  const _AuraScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
