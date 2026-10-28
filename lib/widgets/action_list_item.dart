import 'package:flutter/material.dart';

import 'press_scale.dart';

/// Ítem de lista de 72 dp: ícono dentro de un círculo de 40 dp, título
/// en bodyLarge, texto de apoyo en bodyMedium y, opcionalmente, un
/// chevron al final. Con ripple y leve escala al presionar.
class ActionListItem extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String? subtitle;
  final IconData? trailingIcon;
  final Color background;
  final Color foreground;
  final Color circleColor;
  final Color onCircleColor;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const ActionListItem({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.background,
    required this.foreground,
    required this.circleColor,
    required this.onCircleColor,
    this.subtitle,
    this.trailingIcon = Icons.chevron_right_rounded,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.onTap,
  });

  /// Variante sobre primaryContainer (la que usa la app).
  factory ActionListItem.onPrimaryContainer(
    BuildContext context, {
    Key? key,
    required IconData leadingIcon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    IconData? trailingIcon = Icons.chevron_right_rounded,
  }) {
    final c = Theme.of(context).colorScheme;
    return ActionListItem(
      key: key,
      leadingIcon: leadingIcon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      trailingIcon: trailingIcon,
      background: c.primaryContainer,
      foreground: c.onPrimaryContainer,
      circleColor: c.primary,
      onCircleColor: c.onPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final enabled = onTap != null;

    return PressScale(
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Material(
          color: background,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 72),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(leadingIcon, size: 24, color: onCircleColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style:
                                  text.bodyLarge?.copyWith(color: foreground),
                            ),
                            if (subtitle != null)
                              Text(
                                subtitle!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: text.bodyMedium?.copyWith(
                                  color: foreground.withValues(alpha: 0.8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (trailingIcon != null)
                      Icon(trailingIcon, size: 24, color: foreground),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
