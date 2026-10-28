import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/secure_session.dart';
import 'models/auth_models.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'widgets/transiciones.dart';

/// Permite navegar al login desde fuera de un widget (cuando el
/// servidor avisa que la sesión venció).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.init();

  ApiClient.instance.onSessionExpired = () {
    navigatorKey.currentState?.pushAndRemoveUntil(
      slideRoute(const LoginScreen()),
      (route) => false,
    );
  };

  runApp(const SisstApp());
}

class SisstApp extends StatelessWidget {
  const SisstApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SISSTeApp',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Claro u oscuro según el ajuste del sistema.
      themeMode: ThemeMode.system,
      home: const _SessionGate(),
    );
  }
}

/// Al abrir la app decide a dónde ir:
///
/// - Sin marcador local de sesión -> login.
/// - Con "Mantener sesión" desmarcada al iniciar -> cierra esa sesión
///   y pide iniciar de nuevo.
/// - Con marcador: le pregunta al servidor si la sesión sigue viva
///   (la cookie dura 8 h y se pierde si el servidor se reinicia).
///   Vigente -> Home. Vencida -> limpia y va al login. Si no hay red
///   para preguntar, se deja entrar con el marcador local; si la sesión
///   ya no sirve, la primera petición real recibirá 401 y ApiClient
///   mandará al login.
class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  late final Future<bool> _hasSession = _resolve();

  Future<bool> _resolve() async {
    if (!await SecureSession.instance.hasActiveSession()) return false;

    final auth = AuthService();

    if (!await SecureSession.instance.readKeepSession()) {
      await auth.logout();
      return false;
    }

    final status = await auth.checkSession();
    if (status == SessionStatus.expired) {
      await auth.clearLocalSession();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSession,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return (snapshot.data ?? false)
            ? const MainShell()
            : const LoginScreen();
      },
    );
  }
}
