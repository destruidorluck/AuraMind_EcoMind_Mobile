import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_route.dart';
import '../../core/localization/aura_localizations.dart';
import '../../core/theme/aura_colors.dart';
import '../../core/theme/aura_radii.dart';

import '../../state/aura_scope.dart';
import '../../state/aura_controller.dart';

import '../../widgets/aura_centered_phone_frame.dart';
import '../../widgets/aura_persistent_media_player.dart';
import '../views/aura_views.dart';

class AppShellScreen extends StatelessWidget {
  const AppShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuraController controller = AuraScope.of(context);

    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    final isMobile = screenSize.width < 720;
    final isTablet = screenSize.width >= 720 && screenSize.width < 1024;
    final isPortraitTablet = isTablet && orientation == Orientation.portrait;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (controller.handleSystemBack()) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: AuraPersistentMediaPlayer(
          controller: controller,
          child: isMobile
              ? _MobileLayout(controller: controller)
              : isTablet
                  ? _TabletLayout(
                      controller: controller,
                      isPortrait: isPortraitTablet,
                    )
                  : _DesktopLayout(controller: controller),
        ),
      ),
    );
  }
}

///
/// MOBILE
///
class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.controller,
  });

  final AuraController controller;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 560;
    final bottomPadding = compact ? 74.0 : 104.0;
    return AuraCenteredPhoneFrame(
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _ShellHeader(
                  route: controller.route,
                ),

                Expanded(
                  child: AnimatedSwitcher(
                    duration:
                        const Duration(milliseconds: 220),

                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,

                    child: Padding(
                      key: ValueKey(controller.route),

                      padding: EdgeInsets.only(bottom: bottomPadding),

                      child: AuraRouteView(
                        route: controller.route,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (controller.ringingAlarm != null ||
                controller.ringingTimer != null)
              Positioned.fill(
                child: _RingingOverlay(
                  title:
                      controller.ringingAlarm?.time ??
                          controller
                              .ringingTimer?.duration ??
                          '00:00',

                  subtitle:
                      controller.ringingAlarm?.label ??
                          controller
                              .ringingTimer?.label ??
                          'Alerta',

                  icon:
                      controller.ringingAlarm != null
                          ? Icons.alarm_rounded
                          : Icons.timer_rounded,

                  onStop:
                      controller.ringingAlarm != null
                          ? controller
                              .stopRingingAlarm
                          : controller
                              .stopRingingTimer,
                  onSnooze: controller.ringingAlarm != null
                      ? controller.snoozeRingingAlarm
                      : null,
                ),
              ),

            if (!compact && !_hideFloatingMic(controller.route))
              Positioned(
                right: 16,
                bottom: 92,

                child: _FloatingMicButton(
                  listening:
                      controller.isListening,
                ),
              ),

            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,

              child: _BottomNav(),
            ),

            if (controller.appBrightness < 0.99)
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color:
                        AuraColors.black.withValues(
                      alpha:
                          (1 -
                                  controller
                                      .appBrightness) *
                              0.45,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _hideFloatingMic(AuraRoute route) {
    return switch (route) {
      AuraRoute.auraAsk ||
      AuraRoute.communicateChat ||
      AuraRoute.communicateAnnouncements ||
      AuraRoute.communicateCalling ||
      AuraRoute.play => true,
      _ => false,
    };
  }
}

///
/// TABLET
///
class _TabletLayout extends StatelessWidget {
  const _TabletLayout({
    required this.controller,
    required this.isPortrait,
  });

  final AuraController controller;
  final bool isPortrait;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: isPortrait ? 86 : 100,

                decoration: BoxDecoration(
                  color: isDark
                      ? AuraColors.zinc950.withValues(alpha: 0.94)
                      : AuraColors.white.withValues(alpha: 0.96),
                  border: Border(
                    right: BorderSide(
                      color: isDark ? AuraColors.zinc800 : const Color(0xFFDCE6F2),
                    ),
                  ),
                ),

                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    const Expanded(child: _SidebarNav()),

                    _SidebarProfileButton(
                      controller: controller,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    _ShellHeader(
                      route: controller.route,
                    ),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration:
                            const Duration(
                          milliseconds: 220,
                        ),

                        switchInCurve:
                            Curves.easeOut,

                        switchOutCurve:
                            Curves.easeIn,

                        child: Padding(
                          key: ValueKey(
                            controller.route,
                          ),

                          padding:
                              const EdgeInsets.only(
                            right: 16,
                            bottom: 16,
                          ),

                          child: AuraRouteView(
                            route:
                                controller.route,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (controller.ringingAlarm != null ||
              controller.ringingTimer != null)
            Positioned.fill(
              child: _RingingOverlay(
                title:
                    controller.ringingAlarm?.time ??
                        controller
                            .ringingTimer
                            ?.duration ??
                        '00:00',

                subtitle:
                    controller.ringingAlarm
                            ?.label ??
                        controller
                            .ringingTimer
                            ?.label ??
                        'Alerta',

                icon:
                    controller.ringingAlarm !=
                            null
                        ? Icons.alarm_rounded
                        : Icons.timer_rounded,

                onStop:
                    controller.ringingAlarm !=
                            null
                        ? controller
                            .stopRingingAlarm
                        : controller
                            .stopRingingTimer,
                onSnooze: controller.ringingAlarm != null
                    ? controller.snoozeRingingAlarm
                    : null,
              ),
            ),

          if (controller.appBrightness < 0.99)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color:
                      AuraColors.black
                          .withValues(
                    alpha:
                        (1 -
                                controller
                                    .appBrightness) *
                            0.45,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

///
/// DESKTOP
///
class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.controller,
  });

  final AuraController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 120,

                decoration: BoxDecoration(
                  color: isDark
                      ? AuraColors.zinc950.withValues(alpha: 0.94)
                      : AuraColors.white.withValues(alpha: 0.96),
                  border: Border(
                    right: BorderSide(
                      color: isDark ? AuraColors.zinc800 : const Color(0xFFDCE6F2),
                    ),
                  ),
                ),

                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    const Expanded(child: _SidebarNav()),

                    _SidebarProfileButton(
                      controller: controller,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    _ShellHeader(
                      route: controller.route,
                    ),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration:
                            const Duration(
                          milliseconds: 220,
                        ),

                        switchInCurve:
                            Curves.easeOut,

                        switchOutCurve:
                            Curves.easeIn,

                        child: Padding(
                          key: ValueKey(
                            controller.route,
                          ),

                          padding:
                              const EdgeInsets.all(
                            24,
                          ),

                          child: Center(
                            child:
                                ConstrainedBox(
                              constraints:
                                  const BoxConstraints(
                                maxWidth: 1400,
                              ),

                              child:
                                  AuraRouteView(
                                route:
                                    controller
                                        .route,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (controller.ringingAlarm != null ||
              controller.ringingTimer != null)
            Positioned.fill(
              child: _RingingOverlay(
                title:
                    controller.ringingAlarm?.time ??
                        controller
                            .ringingTimer
                            ?.duration ??
                        '00:00',

                subtitle:
                    controller.ringingAlarm
                            ?.label ??
                        controller
                            .ringingTimer
                            ?.label ??
                        'Alerta',

                icon:
                    controller.ringingAlarm !=
                            null
                        ? Icons.alarm_rounded
                        : Icons.timer_rounded,

                onStop:
                    controller.ringingAlarm !=
                            null
                        ? controller
                            .stopRingingAlarm
                        : controller
                            .stopRingingTimer,
                onSnooze: controller.ringingAlarm != null
                    ? controller.snoozeRingingAlarm
                    : null,
              ),
            ),

          if (controller.appBrightness < 0.99)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color:
                      AuraColors.black
                          .withValues(
                    alpha:
                        (1 -
                                controller
                                    .appBrightness) *
                            0.45,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

///
/// SIDEBAR NAV
///
class _SidebarNav extends StatelessWidget {
  const _SidebarNav();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          _SidebarNavItem(
            route: AuraRoute.home,
            icon: Icons.home_rounded,
            label: context.tr('home'),
          ),
          const SizedBox(height: 12),
          _SidebarNavItem(
            route: AuraRoute.communicate,
            icon: Icons.message_rounded,
            label: context.tr('communicate'),
          ),
          const SizedBox(height: 12),
          _SidebarNavItem(
            route: AuraRoute.play,
            icon: Icons.play_circle_filled_rounded,
            label: context.tr('play'),
          ),
          const SizedBox(height: 12),
          _SidebarNavItem(
            route: AuraRoute.devices,
            icon: Icons.grid_view_rounded,
            label: context.tr('devices'),
          ),
          const SizedBox(height: 12),
          _SidebarNavItem(
            route: AuraRoute.more,
            icon: Icons.menu_rounded,
            label: context.tr('more'),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  const _SidebarNavItem({
    required this.route,
    required this.icon,
    required this.label,
  });

  final AuraRoute route;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AuraController controller =
        AuraScope.of(context);

    final active =
        controller.route.mainRoute == route;

    final color = active
        ? AuraColors.cyan400
        : AuraColors.zinc500;

    return InkWell(
      onTap: () => controller.goMain(route),

      borderRadius:
          BorderRadius.circular(
        AuraRadii.md,
      ),

      child: Container(
        padding:
            const EdgeInsets.all(12),

        decoration: active
            ? BoxDecoration(
                color:
                    AuraColors.cyan500
                        .withValues(
                  alpha: 0.15,
                ),

                borderRadius:
                    BorderRadius.circular(
                  AuraRadii.md,
                ),
              )
            : null,

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Icon(
              icon,
              color: color,
              size:
                  active ? 28 : 24,
            ),

            const SizedBox(height: 4),

            Text(
              label,

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///
/// PROFILE BUTTON
///
class _SidebarProfileButton
    extends StatelessWidget {
  const _SidebarProfileButton({
    required this.controller,
  });

  final AuraController controller;

  @override
  Widget build(BuildContext context) {
    final name = controller.currentAccount?.name ?? 'Aura';
    final image = controller.currentAccount?.imageAsset;
    return InkWell(
      onTap: () =>
          controller.go(AuraRoute.profile),

      borderRadius:
          BorderRadius.circular(
        AuraRadii.full,
      ),

      child: Container(
        width: 60,
        height: 60,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient:
              controller.route.mainRoute ==
                      AuraRoute.profile
                  ? const LinearGradient(
                      colors: [
                        AuraColors.cyan400,
                        Color(0xFF3B82F6),
                      ],
                    )
                  : null,

          color:
              controller.route.mainRoute ==
                      AuraRoute.profile
                  ? null
                  : AuraColors.zinc800,
        ),

        padding:
            const EdgeInsets.all(2),

        child: _AvatarCircle(
          name: name,
          imageUrl: image,
          size: 56,
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.name,
    required this.size,
    this.imageUrl,
  });

  final String name;
  final double size;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final letter = name.characters.firstOrNull?.toUpperCase() ?? 'A';
    final url = imageUrl?.trim() ?? '';
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? AuraColors.zinc900 : AuraColors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: url.startsWith('http')
            ? Image.network(
                url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Text(
                  letter,
                  style: TextStyle(
                    color: isDark ? AuraColors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: size * 0.42,
                  ),
                ),
              )
            : url.isNotEmpty
            ? Image.file(
                File(url),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Text(
                  letter,
                  style: TextStyle(
                    color: isDark ? AuraColors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: size * 0.42,
                  ),
                ),
              )
            : Text(
                letter,
                style: TextStyle(
                  color: isDark ? AuraColors.white : const Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                  fontSize: size * 0.42,
                ),
              ),
      ),
    );
  }
}

///
/// RINGING OVERLAY
///
class _RingingOverlay
    extends StatelessWidget {
  const _RingingOverlay({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onStop,
    this.onSnooze,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onStop;
  final VoidCallback? onSnooze;

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          AuraColors.black.withValues(
        alpha: 0.62,
      ),

      alignment: Alignment.center,

      padding:
          const EdgeInsets.all(28),

      child:
          TweenAnimationBuilder<double>(
        tween:
            Tween(begin: 0.92, end: 1),

        duration:
            const Duration(milliseconds: 260),

        curve: Curves.easeOutBack,

        builder:
            (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },

        child: Container(
          width: double.infinity,

          padding:
              const EdgeInsets.all(22),

          decoration: BoxDecoration(
            color: AuraColors.zinc900,

            borderRadius:
                BorderRadius.circular(
              AuraRadii.xl,
            ),

            border: Border.all(
              color:
                  AuraColors.cyan500
                      .withValues(
                alpha: 0.4,
              ),
            ),
          ),

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              Icon(
                icon,
                color:
                    AuraColors.cyan400,
                size: 44,
              ),

              const SizedBox(height: 12),

              Text(
                title,

                style: const TextStyle(
                  color:
                      AuraColors.white,
                  fontSize: 42,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                subtitle,

                textAlign:
                    TextAlign.center,

                style: const TextStyle(
                  color:
                      AuraColors.zinc400,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  if (onSnooze != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSnooze,
                        icon: const Icon(Icons.snooze_rounded),
                        label: const Text('Soneca'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onStop,
                      icon: const Icon(Icons.stop_rounded),
                      label: const Text('Parar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///
/// HEADER
///
class _ShellHeader extends StatelessWidget {
  const _ShellHeader({
    required this.route,
  });

  final AuraRoute route;

  @override
  Widget build(BuildContext context) {
    final controller = AuraScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final account = controller.currentAccount;
    final userName = account?.name.trim().isNotEmpty == true
        ? account!.name.split(' ').first
        : 'Aura';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      decoration: BoxDecoration(
        color: isDark ? AuraColors.zinc950 : const Color(0xFFF8FBFF),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AuraColors.zinc800.withValues(alpha: 0.55)
                : const Color(0xFFDCE6F2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AuraColors.zinc400 : const Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? AuraColors.white : const Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (route != AuraRoute.home) ...[
                  const SizedBox(height: 2),
                  Text(
                    context.tr(route.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark
                          ? AuraColors.zinc500
                          : const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          if (controller.doNotDisturb) ...[
            const Icon(
              Icons.do_not_disturb_on_rounded,
              color: AuraColors.cyan400,
              size: 20,
            ),
            const SizedBox(width: 10),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${controller.currentTemp}°C',
                style: TextStyle(
                  color: isDark ? AuraColors.white : const Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.water_drop_rounded, size: 11, color: AuraColors.cyan400),
                  const SizedBox(width: 2),
                  Text(
                    '${controller.weatherCondition} • ${controller.location}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? AuraColors.zinc400 : const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => controller.go(AuraRoute.profile),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AuraColors.zinc900 : AuraColors.white,
                border: Border.all(
                  color: isDark ? AuraColors.zinc700 : const Color(0xFFDCE6F2),
                ),
              ),
              child: _AvatarCircle(
                name: userName,
                imageUrl: account?.imageAsset,
                size: 42,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///
/// MIC BUTTON
///
class _FloatingMicButton
    extends StatelessWidget {
  const _FloatingMicButton({
    required this.listening,
  });

  final bool listening;

  @override
  Widget build(BuildContext context) {
    final AuraController controller =
        AuraScope.of(context);
    final stateColor = switch (controller.auraLightState) {
      AuraLightState.processing => AuraColors.purple500,
      AuraLightState.responding => AuraColors.purple500,
      AuraLightState.success => AuraColors.green500,
      AuraLightState.error => AuraColors.red500,
      AuraLightState.listening => AuraColors.cyan500,
      AuraLightState.idle => AuraColors.zinc800,
    };
    final foregroundColor =
        listening || controller.auraLightState != AuraLightState.idle
            ? AuraColors.white
            : AuraColors.cyan400;

    return FloatingActionButton(
      onPressed:
          () => controller.toggleListening(),

      elevation: 10,

      backgroundColor: stateColor,

      foregroundColor: foregroundColor,

      child: const Icon(
        Icons.mic_rounded,
      ),
    );
  }
}

///
/// BOTTOM NAV
///
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 86,

      padding:
          const EdgeInsets.fromLTRB(
        8,
        8,
        8,
        12,
      ),

      decoration: BoxDecoration(
        color: isDark
            ? AuraColors.zinc950.withValues(alpha: 0.94)
            : AuraColors.white.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(
            color: isDark ? AuraColors.zinc800 : const Color(0xFFDCE6F2),
          ),
        ),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,

        children: [
          _NavItem(
            route: AuraRoute.home,
            icon: Icons.home_rounded,
            label: context.tr('home'),
          ),

          _NavItem(
            route: AuraRoute.communicate,
            icon: Icons.message_rounded,
            label: context.tr('communicate'),
          ),

          _NavItem(
            route: AuraRoute.play,
            icon: Icons.play_circle_filled_rounded,
            label: context.tr('play'),
          ),

          _NavItem(
            route: AuraRoute.devices,
            icon: Icons.grid_view_rounded,
            label: context.tr('devices'),
          ),

          _NavItem(
            route: AuraRoute.more,
            icon: Icons.menu_rounded,
            label: context.tr('more'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.route,
    required this.icon,
    required this.label,
  });

  final AuraRoute route;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AuraController controller =
        AuraScope.of(context);

    final active =
        controller.route.mainRoute == route;

    final color = active
        ? AuraColors.cyan400
        : AuraColors.zinc500;

    return InkWell(
      onTap: () =>
          controller.goMain(route),

      borderRadius:
          BorderRadius.circular(
        AuraRadii.lg,
      ),

      child: SizedBox(
        width: 70,

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              color: color,
              size:
                  active ? 28 : 25,
            ),

            const SizedBox(height: 4),

            Text(
              label,

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
