import 'package:flutter/material.dart';

import 'screens/login/login_screen.dart';
import 'screens/shell/app_shell_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'state/aura_controller.dart';

class AppRoot extends StatelessWidget {
  const AppRoot({super.key, required this.controller});

  final AuraController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isAppReady) {
          return SplashScreen(
            isError: controller.hasInitError,
            message: controller.appInitMessage,
            error: controller.appInitError,
            onRetry: controller.hasInitError
                ? () => controller.initializeApp(force: true)
                : null,
          );
        }

        if (!controller.isLoggedIn) {
          return LoginScreen(
            onLogin: ({
              String email = '',
              String provider = 'E-mail',
              String name = '',
            }) {
              controller.login(email: email, provider: provider, name: name);
            },
          );
        }

        return const AppShellScreen();
      },
    );
  }
}
