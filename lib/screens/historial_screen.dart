import 'dart:async';

import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../models/solicitud.dart';
import '../services/constancias_service.dart';
import '../services/solicitudes_service.dart';
import '../utils/errores.dart';
import '../utils/formato.dart';
import '../widgets/estados_vista.dart';
import '../widgets/solicitud_card.dart';
import '../widgets/solicitud_detalle_sheet.dart';

/// Todas las solicitudes del usuario (pendientes y atendidas), de la
/// más reciente a la más antigua, con buscador y descarga de la
/// constancia en las atendidas.
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final _buscarCtrl = TextEditingController();
  Timer? _debounce;

  List<Solicitud> _todas = const [];
  bool _cargando = true;
  String? _error;

  /// Texto ya aplicado al filtro, y si falta aplicar lo último escrito
  /// (mientras tanto se muestra el indicador de progreso).
  String _consulta = '';
  bool _buscando = false;

  final Set<String> _descargando = {};

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _buscarCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await SolicitudesService().listarMias(limite: 500);
      if (!mounted) return;
      setState(() {
        _todas = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = mensajeDe(e);
        _cargando = false;
      });
    }
  }

  void _alEscribir(String valor) {
    _debounce?.cancel();
    setState(() => _buscando = true);
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _consulta = valor;
        _buscando = false;
      });
    });
  }

  void _limpiar() {
    _debounce?.cancel();
    _buscarCtrl.clear();
    setState(() {
      _consulta = '';
      _buscando = false;
    });
  }

  /// Todas las palabras escritas deben aparecer en alguno de los datos
  /// de la solicitud (folio, falla, detalle, descripción, estado,
  /// técnico o fecha), sin distinguir mayúsculas ni acentos.
  List<Solicitud> get _filtradas {
    final palabras = normalizar(_consulta)
        .split(' ')
        .where((p) => p.isNotEmpty)
        .toList();
    if (palabras.isEmpty) return _todas;

    return _todas.where((s) {
      final texto = normalizar([
        s.seguimiento,
        s.categoria,
        s.subcategoria,
        s.detalleTexto,
        s.comentario,
        estadoLegible(s.estado),
        s.tecnico,
        soloFecha(s.fechaCreacion),
      ].whereType<String>().join(' '));
      return palabras.every(texto.contains);
    }).toList();
  }

  Future<void> _descargar(Solicitud s) async {
    if (_descargando.contains(s.seguimiento)) return;
    setState(() => _descargando.add(s.seguimiento));
    try {
      await ConstanciasService().descargarYAbrir(s.seguimiento);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('No se pudo abrir la constancia.')),
          );
      }
    } finally {
      if (mounted) setState(() => _descargando.remove(s.seguimiento));
    }
  }

  Widget? _accionConstancia(Solicitud s) {
    if (s.estado != EstadoSolicitud.atendida) return null;
    if (_descargando.contains(s.seguimiento)) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );
    }
    return IconButton.filledTonal(
      tooltip: 'Descargar constancia',
      onPressed: () => _descargar(s),
      icon: const Icon(Icons.picture_as_pdf_rounded),
    );
  }

  Widget _contenido(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    if (_cargando || _buscando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return EstadoError(mensaje: _error!, onReintentar: _cargar);
    }
    if (_todas.isEmpty) {
      return const EstadoVacio(
        icon: Icons.history_rounded,
        titulo: 'Aún no has hecho solicitudes',
        mensaje: 'Aquí verás el historial de tus solicitudes.',
      );
    }

    final lista = _filtradas;
    if (lista.isEmpty) {
      return const EstadoVacio(
        icon: Icons.search_off_rounded,
        titulo: 'Sin resultados',
        mensaje: 'Prueba con otras palabras.',
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(8),
        itemCount: lista.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) => SolicitudCard(
          solicitud: lista[i],
          color: c.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          trailing: _accionConstancia(lista[i]),
          onTap: () => mostrarDetalleSolicitud(context, lista[i]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SearchBar(
            controller: _buscarCtrl,
            hintText: 'Buscar',
            leading: const Icon(Icons.search_rounded),
            trailing: [
              if (_buscarCtrl.text.isNotEmpty)
                IconButton(
                  tooltip: 'Borrar búsqueda',
                  onPressed: _limpiar,
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
            onChanged: _alEscribir,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: c.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(18),
              ),
              child: _contenido(context),
            ),
          ),
        ),
      ],
    );
  }
}
