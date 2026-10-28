import 'package:flutter/material.dart';

import '../models/solicitud.dart';
import '../utils/formato.dart';
import 'estado_chip.dart';
import 'press_scale.dart';

/// Tarjeta de una solicitud (surfaceContainerHigh, esquinas de 28 dp).
/// La usan Pendientes e Historial; [trailing] permite añadir una acción
/// (p. ej. descargar la constancia).
class SolicitudCard extends StatelessWidget {
  final Solicitud solicitud;
  final VoidCallback onTap;
  final Widget? trailing;
  final BorderRadius borderRadius;

  /// Color de fondo; por defecto surfaceContainerHigh.
  final Color? color;

  const SolicitudCard({
    super.key,
    required this.solicitud,
    required this.onTap,
    this.trailing,
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final titulo = [solicitud.categoria, solicitud.subcategoria]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(' › ');

    return PressScale(
      child: Material(
        color: color ?? c.surfaceContainerHigh,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 128),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              '#${solicitud.seguimiento}',
                              style: t.titleMedium,
                            ),
                            const SizedBox(width: 8),
                            EstadoChip(estado: solicitud.estado),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          titulo.isEmpty ? 'Sin categoría' : titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enviada: ${fechaHora(solicitud.fechaCreacion)}',
                          style: t.bodyMedium?.copyWith(
                            color: c.onSurfaceVariant,
                          ),
                        ),
                        if (solicitud.tecnico != null)
                          Text(
                            'Técnico: ${solicitud.tecnico}',
                            style: t.bodyMedium?.copyWith(
                              color: c.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
