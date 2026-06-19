import 'package:flutter/material.dart';

import 'aura_colors.dart';

class AuraTextStyles {
  static const TextStyle title = TextStyle(
    color: AuraColors.white,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static const TextStyle subtitle = TextStyle(
    color: AuraColors.zinc400,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  static const TextStyle label = TextStyle(
    color: AuraColors.zinc400,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle input = TextStyle(
    color: AuraColors.white,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle button = TextStyle(
    color: AuraColors.black,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
}
