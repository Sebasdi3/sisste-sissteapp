import 'package:flutter/material.dart';

/// Estado vacío (no hay datos todavía).
class EstadoVacio extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String? mensaje;

  const EstadoVacio({
    super.key,
    required this.icon,
    required this.titulo,
    this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: c.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(titulo, style: t.titleMedium, textAlign: TextAlign.center),
            if (mensaje != null) ...[
              const SizedBox(height: 4),
              Text(
                mensaje!,
                style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error de carga con botón para reintentar.
class EstadoError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const EstadoError({
    super.key,
    required this.mensaje,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: c.error),
            const SizedBox(height: 12),
            Text(
              mensaje,
              style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
