import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../models/solicitud.dart';
import '../services/solicitudes_service.dart';
import '../utils/formato.dart';
import 'estado_chip.dart';

/// Hoja inferior con el detalle de una solicitud y su historial de
/// cambios de estado (GET /api/solicitudes/:seguimiento/historial).
Future<void> mostrarDetalleSolicitud(BuildContext context, Solicitud s) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _DetalleSheet(solicitud: s),
  );
}

class _DetalleSheet extends StatefulWidget {
  final Solicitud solicitud;
  const _DetalleSheet({required this.solicitud});

  @override
  State<_DetalleSheet> createState() => _DetalleSheetState();
}

class _DetalleSheetState extends State<_DetalleSheet> {
  late Future<List<CambioEstado>> _historial;

  @override
  void initState() {
    super.initState();
    _historial = SolicitudesService().historial(widget.solicitud.seguimiento);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final s = widget.solicitud;

    Widget fila(String etiqueta, String? valor) {
      if (valor == null || valor.trim().isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              etiqueta,
              style: t.labelMedium?.copyWith(color: c.onSurfaceVariant),
            ),
            Text(valor, style: t.bodyLarge),
          ],
        ),
      );
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Row(
              children: [
                Text('Solicitud #${s.seguimiento}', style: t.titleLarge),
                const SizedBox(width: 12),
                EstadoChip(estado: s.estado),
              ],
            ),
            const SizedBox(height: 16),
            fila('Falla', s.categoria),
            fila('Detalle', s.subcategoria),
            fila('Especificación', s.detalleTexto),
            fila('Descripción', s.comentario),
            fila('Técnico asignado', s.tecnico),
            fila('Enviada', fechaHora(s.fechaCreacion)),
            const SizedBox(height: 8),
            Text('Seguimiento', style: t.titleMedium),
            const SizedBox(height: 8),
            FutureBuilder<List<CambioEstado>>(
              future: _historial,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  final msg = snap.error is ApiException
                      ? (snap.error as ApiException).message
                      : 'No se pudo cargar el seguimiento.';
                  return Text(
                    msg,
                    style: t.bodyMedium?.copyWith(color: c.error),
                  );
                }
                final cambios = snap.data ?? [];
                if (cambios.isEmpty) {
                  return Text(
                    'Sin movimientos todavía.',
                    style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
                  );
                }
                return Column(
                  children: [
                    for (final cambio in cambios.reversed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6, right: 12),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: c.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    estadoLegible(cambio.estadoNuevo),
                                    style: t.bodyLarge,
                                  ),
                                  Text(
                                    [
                                      fechaHora(cambio.fechaHora),
                                      if (cambio.usuario != null &&
                                          cambio.usuario!.isNotEmpty)
                                        cambio.usuario!,
                                    ].join(' · '),
                                    style: t.bodyMedium?.copyWith(
                                      color: c.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
