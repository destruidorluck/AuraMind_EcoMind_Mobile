import 'package:flutter/material.dart';

import '../../core/theme/aura_colors.dart';
import '../../widgets/aura_animated_light.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    required this.isError,
    required this.message,
    this.error,
    this.onRetry,
  });

  final bool isError;
  final String message;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 520;
    final lightSize = compact ? 132.0 : 210.0;
    final logoSize = compact ? 82.0 : 130.0;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF040713), Color(0xFF02030A)],
          ),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuraAnimatedLight(size: lightSize, logoSize: logoSize),
                SizedBox(height: compact ? 10 : 20),
                Text(
                  'Aura Mind',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AuraColors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                SizedBox(height: compact ? 10 : 18),
                if (!isError) const CircularProgressIndicator(strokeWidth: 2),
                if (isError)
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFF59E0B),
                    size: 36,
                  ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AuraColors.zinc300),
                ),
                if (error != null && error!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AuraColors.zinc500),
                  ),
                ],
                if (isError && onRetry != null) ...[
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
