import 'package:flutter/material.dart';

import '../core/theme/aura_text_styles.dart';

class AuraTextField extends StatelessWidget {
  const AuraTextField({
    super.key,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.controller,
    this.initialValue,
    this.suffix,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  }) : assert(
         controller == null || initialValue == null,
         'Use either controller or initialValue, not both.',
       );

  final String label;
  final String hint;
  final bool obscureText;
  final TextEditingController? controller;
  final String? initialValue;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Text(
            label,
            style: AuraTextStyles.label.copyWith(
              color: isDark ? null : const Color(0xFF334155),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          enabled: enabled,
          style: AuraTextStyles.input.copyWith(
            color: isDark ? null : const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        ),
      ],
    );
  }
}
