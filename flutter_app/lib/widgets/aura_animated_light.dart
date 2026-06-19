import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/aura_colors.dart';
import '../state/aura_controller.dart';

class AuraAnimatedLight extends StatefulWidget {
  const AuraAnimatedLight({
    super.key,
    this.size = 190,
    this.logoSize = 112,
    this.listening = false,
    this.state,
    this.assetPath = 'assets/images/logo-light.png',
  });

  final double size;
  final double logoSize;
  final bool listening;
  final AuraLightState? state;
  final String assetPath;

  @override
  State<AuraAnimatedLight> createState() => _AuraAnimatedLightState();
}

class _AuraAnimatedLightState extends State<AuraAnimatedLight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _AuraLightPainter(
                    progress: _controller.value,
                    state: widget.state ??
                        (widget.listening
                            ? AuraLightState.listening
                            : AuraLightState.idle),
                  ),
                ),
              ),
              ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 0.1, sigmaY: 0.1),
                child: Image.asset(
                  widget.assetPath,
                  width: widget.logoSize,
                  height: widget.logoSize,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.auto_awesome_rounded,
                      color: AuraColors.cyan400,
                      size: 58,
                    );
                  },
                ),
              ),
              if ((widget.state == AuraLightState.listening) ||
                  (widget.state == null && widget.listening))
                const _ListeningBars(),
            ],
          );
        },
      ),
    );
  }
}

class _AuraLightPainter extends CustomPainter {
  _AuraLightPainter({required this.progress, required this.state});

  final double progress;
  final AuraLightState state;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final listening = state == AuraLightState.listening;
    final processing = state == AuraLightState.processing;
    final responding = state == AuraLightState.responding;
    final success = state == AuraLightState.success;
    final error = state == AuraLightState.error;
    final primary = error
        ? AuraColors.red500
        : success
            ? AuraColors.green500
            : responding
                ? AuraColors.amber500
                : processing
                    ? AuraColors.purple500
                    : AuraColors.blue500;
    final secondary = error
        ? AuraColors.red400
        : success
            ? AuraColors.green400
            : responding
                ? AuraColors.amber400
                : processing
                    ? AuraColors.purple400
                    : AuraColors.cyan400;
    final pulse = listening || processing || responding
        ? 0.18 * math.sin(progress * math.pi * 6)
        : 0.08 * math.sin(progress * math.pi * 2);
    final baseRadius = size.shortestSide * (0.38 + pulse);

    _paintBlurredGlow(
      canvas,
      center.translate(
        math.sin(progress * math.pi * 2) * 10,
        math.cos(progress * math.pi * 2.4) * 8,
      ),
      baseRadius,
      primary.withValues(alpha: listening || processing ? 0.46 : 0.28),
      primary.withValues(alpha: 0),
      28,
    );

    _paintBlurredGlow(
      canvas,
      center.translate(
        math.cos(progress * math.pi * 1.7) * 18,
        math.sin(progress * math.pi * 2.2) * 14,
      ),
      size.shortestSide * (0.30 + pulse / 2),
      secondary.withValues(alpha: listening || responding ? 0.38 : 0.22),
      secondary.withValues(alpha: 0),
      36,
    );

    _paintBlurredGlow(
      canvas,
      center.translate(-18, 22),
      size.shortestSide * 0.26,
      const Color(0xFF0F172A).withValues(alpha: 0.22),
      const Color(0xFF0F172A).withValues(alpha: 0),
      18,
    );
  }

  void _paintBlurredGlow(
    Canvas canvas,
    Offset center,
    double radius,
    Color inner,
    Color outer,
    double blur,
  ) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          inner,
          inner.withValues(alpha: inner.a * 0.42),
          outer,
        ],
        stops: const [0, 0.42, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    final path = Path();
    const points = 18;
    for (var i = 0; i < points; i++) {
      final angle = (math.pi * 2 / points) * i;
      final wobble = 1 + 0.12 * math.sin(angle * 3 + progress * math.pi * 2);
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * wobble;
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AuraLightPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.state != state;
  }
}

class _ListeningBars extends StatelessWidget {
  const _ListeningBars();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 8, end: 34),
          duration: Duration(milliseconds: 520 + index * 80),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Container(
              width: 5,
              height: index.isEven ? value : 42 - value,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: AuraColors.cyan400,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          },
          onEnd: () {},
        );
      }),
    );
  }
}
