import 'package:flutter/material.dart';

import 'aura_colors.dart';
import 'aura_radii.dart';
import 'aura_text_styles.dart';

final ThemeData auraDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AuraColors.black,
  colorScheme: const ColorScheme.dark(
    primary: AuraColors.purple500,
    secondary: AuraColors.cyan400,
    surface: AuraColors.zinc950,
    onSurface: AuraColors.white,
    onPrimary: AuraColors.white,
  ),
  textTheme: const TextTheme(
    headlineMedium: AuraTextStyles.title,
    bodyMedium: AuraTextStyles.input,
    bodySmall: AuraTextStyles.subtitle,
    labelLarge: AuraTextStyles.button,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AuraColors.zinc900,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuraRadii.lg),
      borderSide: const BorderSide(color: AuraColors.zinc800),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuraRadii.lg),
      borderSide: const BorderSide(color: AuraColors.zinc800),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuraRadii.lg),
      borderSide: const BorderSide(color: AuraColors.purple500),
    ),
    labelStyle: AuraTextStyles.label,
    hintStyle: AuraTextStyles.input.copyWith(color: AuraColors.zinc500),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AuraColors.purple500,
      foregroundColor: AuraColors.white,
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AuraRadii.full),
      ),
      textStyle: AuraTextStyles.button,
      elevation: 0,
    ),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: AuraColors.purple500,
    inactiveTrackColor: AuraColors.cyan500.withValues(alpha: 0.22),
    thumbColor: AuraColors.cyan400,
    overlayColor: AuraColors.purple500.withValues(alpha: 0.18),
  ),
);

final ThemeData auraLightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFDDEBFF),
  colorScheme: const ColorScheme.light(
    primary: AuraColors.purple600,
    secondary: AuraColors.cyan500,
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF111827),
    onPrimary: AuraColors.white,
  ),
  textTheme: TextTheme(
    headlineMedium: AuraTextStyles.title.copyWith(color: const Color(0xFF111827)),
    bodyMedium: AuraTextStyles.input.copyWith(color: const Color(0xFF111827)),
    bodySmall: AuraTextStyles.subtitle.copyWith(color: const Color(0xFF475569)),
    labelLarge: AuraTextStyles.button,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AuraColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuraRadii.lg),
      borderSide: const BorderSide(color: Color(0xFFDCE6F2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuraRadii.lg),
      borderSide: const BorderSide(color: Color(0xFFDCE6F2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuraRadii.lg),
      borderSide: const BorderSide(color: AuraColors.purple600),
    ),
    labelStyle: AuraTextStyles.label.copyWith(color: const Color(0xFF334155)),
    hintStyle: AuraTextStyles.input.copyWith(color: const Color(0xFF94A3B8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AuraColors.purple600,
      foregroundColor: AuraColors.white,
      minimumSize: const Size.fromHeight(56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AuraRadii.full),
      ),
      textStyle: AuraTextStyles.button,
      elevation: 0,
    ),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: AuraColors.purple600,
    inactiveTrackColor: AuraColors.cyan500.withValues(alpha: 0.22),
    thumbColor: AuraColors.cyan500,
    overlayColor: AuraColors.purple600.withValues(alpha: 0.16),
  ),
);
