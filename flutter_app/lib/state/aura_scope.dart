import 'package:flutter/material.dart';

import 'aura_controller.dart';

class AuraScope extends InheritedNotifier<AuraController> {
  const AuraScope({
    super.key,
    required AuraController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuraController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuraScope>();
    assert(scope != null, 'AuraScope not found in widget tree.');
    return scope!.notifier!;
  }

  static AuraController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuraScope>()?.notifier;
  }
}
