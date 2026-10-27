import 'package:flutter/material.dart';

import 'core/secure_session.dart';
import 'screens/home_placeholder_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const SisstApp());
}

class SisstApp extends StatelessWidget {
  const SisstApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SISSTeApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.background,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white10,
          labelStyle: TextStyle(color: Colors.white70),
        ),
      ),
      home: const _SessionGate(),
    );
  }
}

/// Verifica al abrir la app si ya existe un token JWT guardado
/// (RNF-APP-01) y salta directamente a la pantalla principal en ese
/// caso, evitando pedir credenciales en cada apertura de la app.
///
/// Nota: esto valida solo la PRESENCIA del token en el dispositivo,
/// no su vigencia contra el servidor. La verificación de expiración
/// del JWT contra el backend es una mejora natural para un sprint
/// posterior si el equipo decide incorporarla.
class _SessionGate extends StatelessWidget {
  const _SessionGate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SecureSession.instance.hasActiveSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        final hasSession = snapshot.data ?? false;
        return hasSession ? const HomePlaceholderScreen() : const LoginScreen();
      },
    );
  }
}
