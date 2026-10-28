import 'package:flutter/material.dart';

import '../models/solicitud.dart';
import '../services/solicitudes_service.dart';
import '../utils/errores.dart';
import '../widgets/estados_vista.dart';
import '../widgets/solicitud_card.dart';
import '../widgets/solicitud_detalle_sheet.dart';

/// Las 3 solicitudes pendientes (en espera o en proceso) más recientes
/// del usuario. El resto se consulta en Historial.
class PendientesScreen extends StatefulWidget {
  const PendientesScreen({super.key});

  @override
  State<PendientesScreen> createState() => _PendientesScreenState();
}

class _PendientesScreenState extends State<PendientesScreen> {
  late Future<List<Solicitud>> _futuro = _pedir();

  Future<List<Solicitud>> _pedir() => SolicitudesService()
      .listarMias(estado: EstadoSolicitud.pendientes, limite: 3);

  void _reintentar() => setState(() => _futuro = _pedir());

  Future<void> _refrescar() async {
    final f = _pedir();
    setState(() => _futuro = f);
    await f.catchError((_) => <Solicitud>[]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Solicitud>>(
      future: _futuro,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return EstadoError(
            mensaje: mensajeDe(snap.error),
            onReintentar: _reintentar,
          );
        }

        final pendientes = snap.data ?? const <Solicitud>[];

        return RefreshIndicator(
          onRefresh: _refrescar,
          child: pendientes.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    EstadoVacio(
                      icon: Icons.task_alt_rounded,
                      titulo: 'No tienes solicitudes pendientes',
                      mensaje:
                          'Cuando envíes una solicitud aparecerá aquí hasta '
                          'que sea atendida.',
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: pendientes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => SolicitudCard(
                    solicitud: pendientes[i],
                    onTap: () =>
                        mostrarDetalleSolicitud(context, pendientes[i]),
                  ),
                ),
        );
      },
    );
  }
}
