import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/secure_session.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../widgets/banner_error.dart';
import '../widgets/press_scale.dart';
import '../widgets/transiciones.dart';
import 'login_screen.dart';

/// Ajustes: datos de la cuenta, cambio de contraseña y cierre de sesión.
class AjustesScreen extends StatefulWidget {
  /// true si el servidor exige cambiar la contraseña en este inicio de sesión.
  final bool forzarCambio;
  const AjustesScreen({super.key, this.forzarCambio = false});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nuevaCtrl = TextEditingController();
  final _confirmaCtrl = TextEditingController();
  final _auth = AuthService();

  bool _cargando = true;
  String _nombre = '';
  String _rol = '';
  bool _verNueva = false;
  bool _verConfirma = false;
  bool _guardando = false;
  bool _avisoCambio = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _avisoCambio = widget.forzarCambio;
    _cargar();
  }

  @override
  void dispose() {
    _nuevaCtrl.dispose();
    _confirmaCtrl.dispose();
    super.dispose();
  }

  /// Lee los datos de la cuenta y confirma con el servidor que la
  /// sesión sigue activa.
  Future<void> _cargar() async {
    final nombre = await SecureSession.instance.readNombre();
    final rol = await SecureSession.instance.readRol();
    final estado = await _auth.checkSession();
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    if (estado == SessionStatus.expired) {
      await _auth.clearLocalSession();
      _irAlLogin();
      return;
    }

    setState(() {
      _nombre = nombre ?? '';
      _rol = _rolLegible(rol ?? '');
      _cargando = false;
    });
  }

  String _rolLegible(String rol) {
    switch (rol) {
      case 'usuario':
        return 'Usuario';
      case 'tecnico':
        return 'Técnico';
      case 'admin':
        return 'Administrador';
      default:
        return rol.isEmpty ? '' : rol[0].toUpperCase() + rol.substring(1);
    }
  }

  void _irAlLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      slideRoute(const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _cambiarPassword() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      await _auth.cambiarPassword(_nuevaCtrl.text);
      if (!mounted) return;
      _nuevaCtrl.clear();
      _confirmaCtrl.clear();
      setState(() {
        _guardando = false;
        _avisoCambio = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Contraseña actualizada.')));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = 'No se pudo cambiar la contraseña. Intenta nuevamente.';
      });
    }
  }

  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    await _auth.logout();
    if (!mounted) return;
    _irAlLogin();
  }

  /// Caja de 128 dp (surfaceContainerHigh, esquinas de 28 dp) con un
  /// campo de contraseña dentro.
  Widget _caja({required Widget campo}) {
    final c = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: Alignment.center,
      child: campo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: c.primaryContainer,
              child: Icon(Icons.person_rounded, color: c.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nombre.isEmpty ? 'Mi cuenta' : _nombre,
                    style: t.titleMedium,
                  ),
                  if (_rol.isNotEmpty)
                    Text(
                      _rol,
                      style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_avisoCambio) ...[
          const BannerInfo(
            mensaje: 'Por seguridad, debes cambiar tu contraseña antes de '
                'continuar.',
            icon: Icons.lock_reset_rounded,
          ),
          const SizedBox(height: 16),
        ],
        Text('Cambiar contraseña', style: t.titleMedium),
        const SizedBox(height: 12),
        Form(
          key: _formKey,
          child: Column(
            children: [
              _caja(
                campo: TextFormField(
                  controller: _nuevaCtrl,
                  enabled: !_guardando,
                  obscureText: !_verNueva,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      tooltip: _verNueva ? 'Ocultar' : 'Mostrar',
                      onPressed: () => setState(() => _verNueva = !_verNueva),
                      icon: Icon(
                        _verNueva
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Escribe la nueva contraseña';
                    if (v.length < 4) return 'Debe tener al menos 4 caracteres';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),
              _caja(
                campo: TextFormField(
                  controller: _confirmaCtrl,
                  enabled: !_guardando,
                  obscureText: !_verConfirma,
                  decoration: InputDecoration(
                    labelText: 'Confirmar nueva contraseña',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      tooltip: _verConfirma ? 'Ocultar' : 'Mostrar',
                      onPressed: () =>
                          setState(() => _verConfirma = !_verConfirma),
                      icon: Icon(
                        _verConfirma
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirma la contraseña';
                    if (v != _nuevaCtrl.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          BannerError(mensaje: _error!),
        ],
        const SizedBox(height: 16),
        if (_guardando)
          const Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: CircularProgressIndicator(),
              ),
            ),
          )
        else
          Align(
            alignment: Alignment.centerRight,
            child: PressScale(
              child: FilledButton(
                onPressed: _cambiarPassword,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Cambiar Contraseña'),
                    SizedBox(width: 8),
                    Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: PressScale(
            child: OutlinedButton.icon(
              onPressed: _guardando ? null : _cerrarSesion,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesión'),
            ),
          ),
        ),
      ],
    );
  }
}
