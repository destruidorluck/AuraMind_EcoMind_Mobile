import 'package:flutter/material.dart';

import '../core/theme/aura_colors.dart';

class AuraAdaptiveFrame extends StatelessWidget {
  const AuraAdaptiveFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isPhone = width < 700;
        final maxWidth = width >= 1200 ? 1040.0 : (width >= 700 ? 760.0 : 430.0);
        final horizontalPadding = isPhone ? 0.0 : 24.0;
        final verticalPadding = isPhone ? 0.0 : 20.0;

        return ColoredBox(
          color: Theme.of(context).brightness == Brightness.dark
              ? AuraColors.black
              : const Color(0xFFE8F0FB),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: Theme.of(context).brightness == Brightness.dark
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF050711), Color(0xFF02030A)],
                        )
                      : const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFF4F8FF), Color(0xFFE2EDFF)],
                        ),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AuraColors.zinc950
                          : Colors.white.withValues(alpha: 0.97),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AuraColors.zinc800
                            : const Color(0xFFCFE0F7),
                      ),
                      borderRadius: BorderRadius.circular(isPhone ? 0 : 28),
                      boxShadow: isPhone
                          ? null
                          : [
                              BoxShadow(
                                color: AuraColors.black.withValues(alpha: 0.18),
                                blurRadius: 42,
                                offset: const Offset(0, 20),
                              ),
                            ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isPhone ? 0 : 28),
                      child: SizedBox.expand(child: child),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
