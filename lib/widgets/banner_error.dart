import 'package:flutter/material.dart';

/// Aviso de error en línea (errorContainer), para formularios.
class BannerError extends StatelessWidget {
  final String mensaje;
  const BannerError({super.key, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 20, color: c.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: t.bodyMedium?.copyWith(color: c.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso informativo en línea (secondaryContainer).
class BannerInfo extends StatelessWidget {
  final String mensaje;
  final IconData icon;
  const BannerInfo({
    super.key,
    required this.mensaje,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: c.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: t.bodyMedium?.copyWith(color: c.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
