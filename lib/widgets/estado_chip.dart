import 'package:flutter/material.dart';

import '../models/solicitud.dart';
import '../utils/formato.dart';

/// Etiqueta con el estado de una solicitud, coloreada por rol:
/// en espera (tertiary), en proceso (primary), atendida (secondary).
class EstadoChip extends StatelessWidget {
  final String estado;
  const EstadoChip({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final Color bg;
    final Color fg;
    switch (estado) {
      case EstadoSolicitud.enProceso:
        bg = c.primaryContainer;
        fg = c.onPrimaryContainer;
      case EstadoSolicitud.atendida:
        bg = c.secondaryContainer;
        fg = c.onSecondaryContainer;
      default:
        bg = c.tertiaryContainer;
        fg = c.onTertiaryContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        estadoLegible(estado),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
      ),
    );
  }
}
