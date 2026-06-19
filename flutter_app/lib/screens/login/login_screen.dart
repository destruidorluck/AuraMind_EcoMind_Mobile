import 'package:flutter/material.dart';

import '../../core/localization/aura_localizations.dart';
import '../../core/theme/aura_colors.dart';
import '../../core/theme/aura_spacing.dart';
import '../../services/aura_auth_service.dart';
import '../../widgets/aura_adaptive_frame.dart';
import '../../widgets/aura_animated_light.dart';
import '../../widgets/aura_primary_button.dart';
import '../../widgets/aura_text_field.dart';

typedef AuraLoginCallback = void Function({
  String email,
  String provider,
  String name,
});

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});

  final AuraLoginCallback onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _acceptedTerms = false;
  bool _showPassword = false;
  bool _submitting = false;
  String? _feedback;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (!_acceptedTerms) {
      setState(() => _feedback = context.tr('accept_terms'));
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!email.contains('@') || password.trim().length < 6) {
      setState(() => _feedback = context.tr('login_fields_invalid'));
      return;
    }

    setState(() {
      _submitting = true;
      _feedback = null;
    });

    try {
      final message = await AuraAuthService.signInWithEmail(email, password);
      setState(() => _feedback = message);
      final user = AuraAuthService.client?.auth.currentUser;
      widget.onLogin(
        email: email,
        provider: 'E-mail',
        name: user == null ? '' : AuraAuthService.displayNameFromUser(user),
      );
    } catch (error) {
      setState(() => _feedback = '${context.tr('error')}: $error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _recoverPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _feedback = context.tr('password_invalid'));
      return;
    }

    setState(() {
      _submitting = true;
      _feedback = null;
    });

    try {
      final message = await AuraAuthService.recoverPassword(email);
      setState(() => _feedback = message);
    } catch (error) {
      setState(() => _feedback = '${context.tr('error')}: $error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _social(AuraAuthProvider provider) async {
    if (!_acceptedTerms) {
      setState(() => _feedback = context.tr('social_login_warning'));
      return;
    }

    setState(() {
      _submitting = true;
      _feedback = null;
    });

    try {
      final message = await AuraAuthService.signInWithProvider(provider);
      setState(() => _feedback = message);
      if (!AuraAuthService.isConfigured) {
        widget.onLogin(provider: _providerLabel(provider));
      }
    } catch (error) {
      setState(() => _feedback = '${context.tr('login_social_unavailable')}$error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _providerLabel(AuraAuthProvider provider) {
    return switch (provider) {
      AuraAuthProvider.apple => 'Apple',
      AuraAuthProvider.microsoft => 'Microsoft',
      AuraAuthProvider.google => 'Google',
    };
  }

  void _showLegal(String title, String body) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text(body, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.tr('understood')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldGap = MediaQuery.sizeOf(context).height < 720 ? 10.0 : 16.0;

    return Scaffold(
      body: AuraAdaptiveFrame(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final compact = constraints.maxHeight < 720;

              final form = ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 520 : 620),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isWide) ...[
                      Align(
                        child: AuraAnimatedLight(
                          size: compact ? 150 : 210,
                          logoSize: compact ? 96 : 142,
                        ),
                      ),
                      SizedBox(height: compact ? 16 : AuraSpacing.xl),
                      Text(
                        context.tr('welcome_title'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AuraColors.white : const Color(0xFF0F172A),
                          fontSize: compact ? 34 : 44,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('welcome_subtitle'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AuraColors.zinc400 : const Color(0xFF64748B),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: compact ? 18 : AuraSpacing.xl),
                    ],
                    if (!AuraAuthService.isConfigured) ...[
                      _FeedbackCard(text: context.tr('supabase_not_configured')),
                      const SizedBox(height: 14),
                    ],
                    AuraTextField(
                      label: context.tr('email'),
                      hint: context.tr('email_placeholder'),
                      controller: _emailController,
                    ),
                    SizedBox(height: fieldGap),
                    AuraTextField(
                      label: context.tr('password'),
                      hint: context.tr('password_placeholder'),
                      obscureText: !_showPassword,
                      controller: _passwordController,
                      suffix: IconButton(
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _submitting ? null : _recoverPassword,
                        child: Text(context.tr('recover_password')),
                      ),
                    ),
                    _TermsRow(
                      accepted: _acceptedTerms,
                      onChanged: (value) => setState(() => _acceptedTerms = value),
                      onTerms: () => _showLegal(
                        context.tr('terms'),
                        context.tr('terms_text'),
                      ),
                      onPrivacy: () => _showLegal(
                        context.tr('privacy_policy'),
                        context.tr('privacy_policy_text'),
                      ),
                    ),
                    const SizedBox(height: AuraSpacing.md),
                    AuraPrimaryButton(
                      label: _submitting
                          ? context.tr('signing_in')
                          : context.tr('sign_in'),
                      onPressed: _submitting ? () {} : _submitEmail,
                    ),
                    const SizedBox(height: AuraSpacing.lg),
                    Text(
                      context.tr('or_continue_with'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? AuraColors.zinc500 : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialIconButton(
                          label: 'Google',
                          onTap: _submitting
                              ? null
                              : () => _social(AuraAuthProvider.google),
                          child: const _GoogleMark(size: 24),
                        ),
                        const SizedBox(width: 12),
                        _SocialIconButton(
                          label: 'Microsoft',
                          onTap: _submitting
                              ? null
                              : () => _social(AuraAuthProvider.microsoft),
                          child: const _MicrosoftMark(size: 22),
                        ),
                        const SizedBox(width: 12),
                        _SocialIconButton(
                          label: 'Apple',
                          onTap: _submitting
                              ? null
                              : () => _social(AuraAuthProvider.apple),
                          child: Icon(
                            Icons.apple_rounded,
                            color: isDark ? AuraColors.white : const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    if (_feedback != null) ...[
                      const SizedBox(height: AuraSpacing.lg),
                      _FeedbackCard(text: _feedback!),
                    ],
                  ],
                ),
              );

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 32 : 30,
                  vertical: compact ? 16 : 28,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: isWide
                      ? Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AuraAnimatedLight(size: 260, logoSize: 170),
                                  const SizedBox(height: 28),
                                  Text(
                                    context.tr('welcome_title'),
                                    style: TextStyle(
                                      color: isDark
                                          ? AuraColors.white
                                          : const Color(0xFF0F172A),
                                      fontSize: 46,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    context.tr('welcome_subtitle'),
                                    style: TextStyle(
                                      color: isDark
                                          ? AuraColors.zinc400
                                          : const Color(0xFF64748B),
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 36),
                            form,
                          ],
                        )
                      : Center(child: form),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({
    required this.accepted,
    required this.onChanged,
    required this.onTerms,
    required this.onPrivacy,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: accepted,
          onChanged: (value) => onChanged(value ?? false),
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('${context.tr('i_agree')} '),
                InkWell(
                  onTap: onTerms,
                  child: Text(
                    context.tr('terms'),
                    style: const TextStyle(
                      color: AuraColors.cyan400,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(' ${context.tr('and')} '),
                InkWell(
                  onTap: onPrivacy,
                  child: Text(
                    context.tr('privacy_policy'),
                    style: const TextStyle(
                      color: AuraColors.cyan400,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({
    required this.label,
    required this.child,
    required this.onTap,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? AuraColors.zinc900 : AuraColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AuraColors.zinc700 : const Color(0xFFDCE6F2),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _GoogleMarkPainter());
  }
}

class _GoogleMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect.deflate(stroke / 2), -0.18, 1.58, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect.deflate(stroke / 2), 1.35, 1.55, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect.deflate(stroke / 2), 2.78, 1.18, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect.deflate(stroke / 2), 3.85, 1.34, false, paint);

    final bar = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.52),
      Offset(size.width * 0.94, size.height * 0.52),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MicrosoftMark extends StatelessWidget {
  const _MicrosoftMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFFF35022),
      Color(0xFF7FBA00),
      Color(0xFF00A4EF),
      Color(0xFFFFB900),
    ];
    final tile = (size - 3) / 2;
    return SizedBox(
      width: size,
      height: size,
      child: Wrap(
        spacing: 3,
        runSpacing: 3,
        children: [
          for (final color in colors)
            Container(width: tile, height: tile, color: color),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AuraColors.cyan500.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.cyan500.withValues(alpha: 0.25)),
      ),
      child: Text(text, style: const TextStyle(color: AuraColors.cyan400)),
    );
  }
}
