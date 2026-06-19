import 'package:flutter/material.dart';

import 'aura_adaptive_frame.dart';

class AuraCenteredPhoneFrame extends StatelessWidget {
  const AuraCenteredPhoneFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AuraAdaptiveFrame(child: child);
  }
}
