import 'package:flutter/material.dart';

import '../core/theme/aura_colors.dart';
import '../core/theme/aura_radii.dart';
import '../core/theme/aura_spacing.dart';
import '../models/aura_models.dart';

class AuraSection extends StatelessWidget {
  const AuraSection({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AuraSpacing.lg),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AuraColors.zinc900.withValues(alpha: 0.62) : Colors.white,
        borderRadius: BorderRadius.circular(AuraRadii.xl),
        border: Border.all(
          color: isDark
              ? AuraColors.zinc800.withValues(alpha: 0.65)
              : const Color(0xFFDCE6F2),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: child,
    );
  }
}

class AuraActionIcon extends StatelessWidget {
  const AuraActionIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AuraRadii.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AuraColors.zinc300,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AuraFilterChip extends StatelessWidget {
  const AuraFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuraRadii.full),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AuraColors.cyan500.withValues(alpha: 0.14)
                : isDark
                    ? AuraColors.zinc900
                    : Colors.white,
            borderRadius: BorderRadius.circular(AuraRadii.full),
            border: Border.all(
              color: selected ? AuraColors.cyan500 : AuraColors.zinc800,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? AuraColors.cyan400
                  : isDark
                      ? AuraColors.zinc300
                      : const Color(0xFF334155),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class AuraSwitch extends StatelessWidget {
  const AuraSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 26,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? AuraColors.cyan500 : AuraColors.zinc700,
          borderRadius: BorderRadius.circular(AuraRadii.full),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: AuraColors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class AuraListTile extends StatelessWidget {
  const AuraListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.color = AuraColors.cyan500,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AuraRadii.lg),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AuraColors.zinc900.withValues(alpha: 0.46) : Colors.white,
          borderRadius: BorderRadius.circular(AuraRadii.lg),
          border: Border.all(
            color: isDark
                ? AuraColors.zinc800.withValues(alpha: 0.46)
                : const Color(0xFFDCE6F2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? AuraColors.zinc100 : const Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: isDark ? AuraColors.zinc500 : const Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AuraColors.zinc500 : const Color(0xFF94A3B8),
                ),
          ],
        ),
      ),
    );
  }
}

class AuraContactCard extends StatelessWidget {
  const AuraContactCard({
    super.key,
    required this.contact,
    this.subtitle,
    this.onTap,
  });

  final AuraContact contact;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AuraListTile(
      icon: Icons.phone_rounded,
      title: contact.name,
      subtitle: subtitle ?? '${contact.type} • ${contact.time}',
      onTap: onTap,
    );
  }
}

class AuraDeviceCard extends StatelessWidget {
  const AuraDeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    required this.onToggle,
    this.onSettings,
  });

  final AuraDevice device;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 560 || size.width > size.height;
    final padding = compact ? 12.0 : 16.0;
    final iconSize = compact ? 38.0 : 42.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AuraRadii.xl),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: device.active
              ? isDark
                  ? AuraColors.zinc900.withValues(alpha: 0.84)
                  : const Color(0xFFEFFBFF)
              : isDark
                  ? AuraColors.zinc900.withValues(alpha: 0.42)
                  : Colors.white,
          borderRadius: BorderRadius.circular(AuraRadii.xl),
          border: Border.all(
            color: device.active
                ? AuraColors.cyan500.withValues(alpha: 0.26)
                : isDark
                    ? AuraColors.zinc800.withValues(alpha: 0.58)
                    : const Color(0xFFDCE6F2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: device.active
                        ? AuraColors.cyan500.withValues(alpha: 0.16)
                        : isDark
                            ? AuraColors.zinc800
                            : const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    device.icon,
                    color: device.active
                        ? AuraColors.cyan400
                        : isDark ? AuraColors.zinc400 : const Color(0xFF64748B),
                    size: 22,
                  ),
                ),
                AuraSwitch(value: device.active, onChanged: (_) => onToggle()),
              ],
            ),
            SizedBox(height: compact ? 12 : 22),
            Text(
              device.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? AuraColors.zinc100 : const Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                fontSize: compact ? 14 : null,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              device.room,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? AuraColors.zinc500 : const Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    device.status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: device.active
                          ? AuraColors.cyan400
                          : isDark ? AuraColors.zinc500 : const Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onSettings != null)
                  InkWell(
                    onTap: onSettings,
                    borderRadius: BorderRadius.circular(AuraRadii.full),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.settings_rounded,
                        color: isDark ? AuraColors.zinc500 : const Color(0xFF64748B),
                        size: 18,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AuraMediaCard extends StatelessWidget {
  const AuraMediaCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AuraRadii.lg),
      child: SizedBox(
        width: 132,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AuraRadii.lg),
              child: Image.network(
                imageUrl,
                width: 132,
                height: 132,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 132,
                    height: 132,
                    color: AuraColors.zinc800,
                    child: const Icon(
                      Icons.play_circle_fill_rounded,
                      color: AuraColors.cyan400,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AuraColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AuraColors.zinc500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
