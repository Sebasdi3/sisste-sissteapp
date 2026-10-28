import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/app_nav_bar.dart';
import '../widgets/banner_error.dart';
import '../widgets/press_scale.dart';
import '../widgets/transiciones.dart';
import 'main_shell.dart';

/// Inicio de sesión. El campo USUARIO es la cédula registrada en el
/// sistema; con "Mantener sesión" marcada la app entra directo al Home
/// la próxima vez que se abra.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _auth = AuthService();

  bool _verPassword = false;
  bool _mantener = true;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_cargando || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _cargando = true;
      _error = null;
    });

    final resultado = await _auth.login(
      cedula: _usuarioCtrl.text.trim(),
      password: _passwordCtrl.text,
      keepSession: _mantener,
    );
    if (!mounted) return;

    if (!resultado.success) {
      setState(() {
        _cargando = false;
        _error = resultado.message;
      });
      return;
    }

    final debeCambiar = resultado.data?.debeCambiarPassword ?? false;
    Navigator.of(context).pushAndRemoveUntil(
      slideRoute(
        MainShell(
          initialTab: debeCambiar ? Destinos.ajustes : Destinos.home,
          forzarCambioPassword: debeCambiar,
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Marcador de posición del logo (200 × 200 dp).
                    Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: c.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.support_agent_rounded,
                          size: 88,
                          color: c.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usuarioCtrl,
                      enabled: !_cargando,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(
                        labelText: 'USUARIO',
                        prefixIcon: Icon(Icons.person_rounded),
                        helperText: 'Ejemplo: 12345678',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa tu usuario'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // El indicador de progreso se dibuja encima del campo
                    // de contraseña mientras se valida el acceso.
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        TextFormField(
                          controller: _passwordCtrl,
                          enabled: !_cargando,
                          obscureText: !_verPassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _entrar(),
                          decoration: InputDecoration(
                            labelText: 'CONTRASEÑA',
                            prefixIcon: const Icon(Icons.key_rounded),
                            helperText: '***********',
                            suffixIcon: IconButton(
                              tooltip: _verPassword
                                  ? 'Ocultar contraseña'
                                  : 'Mostrar contraseña',
                              onPressed: () =>
                                  setState(() => _verPassword = !_verPassword),
                              icon: Icon(
                                _verPassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                              ),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Ingresa tu contraseña'
                              : null,
                        ),
                        if (_cargando)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 22),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: _cargando
                            ? null
                            : () => setState(() => _mantener = !_mantener),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: _mantener,
                                onChanged: _cargando
                                    ? null
                                    : (v) =>
                                        setState(() => _mantener = v ?? false),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Mantener sesion activa en el dispositivo',
                                  style: t.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      BannerError(mensaje: _error!),
                    ],
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: 256,
                        child: PressScale(
                          child: FilledButton(
                            onPressed: _cargando ? null : _entrar,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Iniciar Sesión'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
