import 'package:flutter/material.dart';

import '../core/secure_session.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

/// Pantalla intencionalmente mínima.
///
/// Tal como se documenta en el Informe Parcial (Sprint 1): "si el
/// usuario ingresa, la app mostrará una pantalla en blanco o un
/// mensaje de Bienvenido; el resto de las interfaces aún no
/// existirán." El resto de las pantallas (formulario con cámara,
/// dashboard técnico) se construyen en los Sprints 2 y 3.
class HomePlaceholderScreen extends StatefulWidget {
  const HomePlaceholderScreen({super.key});

  @override
  State<HomePlaceholderScreen> createState() => _HomePlaceholderScreenState();
}

class _HomePlaceholderScreenState extends State<HomePlaceholderScreen> {
  String _nombre = '';

  @override
  void initState() {
    super.initState();
    _loadNombre();
  }

  Future<void> _loadNombre() async {
    final nombre = await SecureSession.instance.readNombre();
    if (mounted) setState(() => _nombre = nombre ?? '');
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 56),
                const SizedBox(height: 16),
                Text(
                  _nombre.isNotEmpty ? 'Bienvenido, $_nombre' : 'Bienvenido',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sesión iniciada correctamente.\n'
                  'El formulario de solicitudes se habilita en el Sprint 2.',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.white70),
                  label: const Text('Cerrar sesión', style: TextStyle(color: Colors.white70)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
