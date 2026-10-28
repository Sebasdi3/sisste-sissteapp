import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/api_client.dart';
import '../models/categoria.dart';
import '../services/categorias_service.dart';
import '../services/solicitudes_service.dart';
import '../utils/errores.dart';
import '../widgets/action_list_item.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/banner_error.dart';
import '../widgets/estados_vista.dart';
import '../widgets/press_scale.dart';
import '../widgets/transiciones.dart';
import 'main_shell.dart';
import 'solicitud_enviada_screen.dart';

/// Formulario de nueva solicitud: falla (categoría), detalle
/// (subcategoría), descripción escrita opcional y foto opcional.
class CrearSolicitudScreen extends StatefulWidget {
  const CrearSolicitudScreen({super.key});

  @override
  State<CrearSolicitudScreen> createState() => _CrearSolicitudScreenState();
}

class _CrearSolicitudScreenState extends State<CrearSolicitudScreen> {
  final _categoriaKey = GlobalKey();
  final _detalleKey = GlobalKey();
  final _comentarioCtrl = TextEditingController();
  final _especifiqueCtrl = TextEditingController();
  final _picker = ImagePicker();

  List<Categoria> _categorias = const [];
  bool _cargando = true;
  String? _errorCarga;

  Categoria? _categoria;
  Subcategoria? _sub;
  bool _escrita = false;
  XFile? _foto;

  bool _enviando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    _especifiqueCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarCategorias() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });
    try {
      final lista = await CategoriasService().listar();
      if (!mounted) return;
      setState(() {
        _categorias = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorCarga = mensajeDe(e);
        _cargando = false;
      });
    }
  }

  /// Menú desplegable justo debajo del ítem identificado con [anchor].
  Future<T?> _menu<T>(GlobalKey anchor, List<PopupMenuEntry<T>> items) {
    final box = anchor.currentContext!.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final origen =
        box.localToGlobal(Offset(0, box.size.height), ancestor: overlay);
    final posicion = RelativeRect.fromLTRB(
      origen.dx,
      origen.dy + 4,
      overlay.size.width - origen.dx - box.size.width,
      0,
    );
    return showMenu<T>(
      context: context,
      position: posicion,
      items: items,
      constraints: BoxConstraints(
        minWidth: box.size.width,
        maxWidth: box.size.width,
        maxHeight: 360,
      ),
    );
  }

  Future<void> _elegirCategoria() async {
    final id = await _menu<int>(_categoriaKey, [
      for (final c in _categorias)
        PopupMenuItem<int>(value: c.id, child: Text(c.nombre)),
    ]);
    if (id == null || !mounted) return;
    setState(() {
      _categoria = _categorias.firstWhere((c) => c.id == id);
      _sub = null;
      _especifiqueCtrl.clear();
      _error = null;
    });
  }

  Future<void> _elegirSub() async {
    final cat = _categoria;
    if (cat == null) return;
    final id = await _menu<int>(_detalleKey, [
      for (final s in cat.subcategorias)
        PopupMenuItem<int>(value: s.id, child: Text(s.nombre)),
    ]);
    if (id == null || !mounted) return;
    setState(() {
      _sub = cat.subcategorias.firstWhere((s) => s.id == id);
      _error = null;
    });
  }

  Future<void> _tomarFoto() async {
    try {
      final f = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (f != null && mounted) setState(() => _foto = f);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la cámara.')),
        );
    }
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();

    final cat = _categoria;
    final sub = _sub;

    if (cat == null) {
      setState(() => _error = 'Selecciona la falla.');
      return;
    }
    if (cat.subcategorias.isNotEmpty && sub == null) {
      setState(() => _error = 'Selecciona el detalle de la falla.');
      return;
    }
    if (sub != null &&
        sub.permiteTextoLibre &&
        _especifiqueCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Especifica el detalle de la falla.');
      return;
    }

    setState(() {
      _enviando = true;
      _error = null;
    });

    try {
      final folio = await SolicitudesService().crear(
        categoriaId: cat.id,
        subcategoriaId: sub?.id,
        detalleTexto:
            sub != null && sub.permiteTextoLibre ? _especifiqueCtrl.text.trim() : null,
        comentario: _escrita ? _comentarioCtrl.text.trim() : null,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        slideRoute(SolicitudEnviadaScreen(seguimiento: folio)),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _error = 'No se pudo enviar la solicitud. Intenta nuevamente.';
      });
    }
  }

  Widget _formulario(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final cat = _categoria;
    final sub = _sub;

    final detalleHabilitado = cat != null && cat.subcategorias.isNotEmpty;
    final detalleSubtitulo = cat == null
        ? 'Primero selecciona la falla'
        : cat.subcategorias.isEmpty
            ? 'Esta falla no tiene opciones adicionales'
            : (sub?.nombre ?? 'Toca para elegir');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ActionListItem.onPrimaryContainer(
          context,
          key: _categoriaKey,
          leadingIcon: Icons.person_rounded,
          title: 'Seleccione Aquí Su Falla',
          subtitle: cat?.nombre ?? 'Toca para elegir',
          onTap: _enviando ? null : _elegirCategoria,
        ),
        const SizedBox(height: 12),
        ActionListItem.onPrimaryContainer(
          context,
          key: _detalleKey,
          leadingIcon: Icons.person_rounded,
          title: 'Detalle De La Falla',
          subtitle: detalleSubtitulo,
          onTap: (detalleHabilitado && !_enviando) ? _elegirSub : null,
        ),
        if (sub != null && sub.permiteTextoLibre) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _especifiqueCtrl,
            enabled: !_enviando,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Especifique el detalle',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: PressScale(
            child: _escrita
                ? TextButton.icon(
                    onPressed: _enviando
                        ? null
                        : () => setState(() => _escrita = false),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Descripcion Escrita'),
                  )
                : FilledButton.tonalIcon(
                    onPressed: _enviando
                        ? null
                        : () => setState(() => _escrita = true),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Descripcion Escrita'),
                  ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          alignment: Alignment.topCenter,
          child: _escrita
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextField(
                    controller: _comentarioCtrl,
                    enabled: !_enviando,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Describe la falla',
                      alignLabelWithHint: true,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: PressScale(
            child: FilledButton.tonalIcon(
              onPressed: _enviando ? null : _tomarFoto,
              icon: const Icon(Icons.photo_camera_rounded),
              label: const Text('Foto de la falla'),
            ),
          ),
        ),
        if (_foto != null) ...[
          const SizedBox(height: 12),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: Image.file(File(_foto!.path), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filledTonal(
                  tooltip: 'Quitar foto',
                  onPressed: _enviando ? null : () => setState(() => _foto = null),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'La foto se guarda en tu teléfono. El servidor todavía no recibe '
            'imágenes, así que no se envía con la solicitud.',
            style: t.bodySmall?.copyWith(color: c.onSurfaceVariant),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 16),
          BannerError(mensaje: _error!),
        ],
        const SizedBox(height: 24),
        if (_enviando) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: PressScale(
            child: FilledButton.icon(
              onPressed: _enviando ? null : _enviar,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Enviar Solicitud'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget cuerpo;
    if (_cargando) {
      cuerpo = const Center(child: CircularProgressIndicator());
    } else if (_errorCarga != null) {
      cuerpo = EstadoError(mensaje: _errorCarga!, onReintentar: _cargarCategorias);
    } else if (_categorias.isEmpty) {
      cuerpo = const EstadoVacio(
        icon: Icons.inbox_rounded,
        titulo: 'No hay fallas disponibles',
        mensaje: 'El administrador aún no ha configurado las categorías '
            'de soporte.',
      );
    } else {
      cuerpo = _formulario(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('SISSTeApp : Crear Solicitud')),
      body: cuerpo,
      bottomNavigationBar: AppNavBar(
        selectedIndex: Destinos.home,
        onSelected: (i) => irATab(context, i),
      ),
    );
  }
}
