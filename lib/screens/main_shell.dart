import 'package:flutter/material.dart';

import '../widgets/app_nav_bar.dart';
import 'ajustes_screen.dart';
import 'historial_screen.dart';
import 'home_screen.dart';
import 'pendientes_screen.dart';

/// Pestaña activa de la barra de navegación. Es global para que
/// pantallas que están "encima" del contenedor (Crear solicitud,
/// Solicitud enviada) puedan mandar al usuario a otra pestaña.
final ValueNotifier<int> tabActual = ValueNotifier<int>(Destinos.home);

/// Cierra las pantallas apiladas (Crear solicitud, Solicitud enviada…)
/// y deja abierta la pestaña [tab].
void irATab(BuildContext context, int tab) {
  Navigator.of(context).popUntil((r) => r.isFirst);
  tabActual.value = tab;
}

/// Contenedor de las 4 pantallas principales: barra superior, cuerpo
/// que cambia con un deslizamiento desde la derecha y barra de
/// navegación inferior compartida.
class MainShell extends StatefulWidget {
  final int initialTab;

  /// true cuando el servidor indicó que el usuario debe cambiar su
  /// contraseña en este primer inicio de sesión.
  final bool forzarCambioPassword;

  const MainShell({
    super.key,
    this.initialTab = Destinos.home,
    this.forzarCambioPassword = false,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _titulos = [
    'SISSTeApp',
    'SISSTeApp : Sol. Pendientes',
    'SISSTeApp : Historial',
    'SISSTeApp : Ajustes',
  ];

  @override
  void initState() {
    super.initState();
    tabActual.value = widget.initialTab;
    tabActual.addListener(_alCambiarTab);
  }

  @override
  void dispose() {
    tabActual.removeListener(_alCambiarTab);
    super.dispose();
  }

  void _alCambiarTab() {
    if (mounted) setState(() {});
  }

  Widget _pantalla(int i) {
    switch (i) {
      case Destinos.pendientes:
        return const PendientesScreen();
      case Destinos.historial:
        return const HistorialScreen();
      case Destinos.ajustes:
        return AjustesScreen(forzarCambio: widget.forzarCambioPassword);
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = tabActual.value;

    return PopScope(
      // En Home, "atrás" cierra la app; en las demás pestañas vuelve a Home.
      canPop: index == Destinos.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) tabActual.value = Destinos.home;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_titulos[index])),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 380),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          layoutBuilder: (current, previous) => Stack(
            fit: StackFit.expand,
            children: [...previous, if (current != null) current],
          ),
          transitionBuilder: (child, animation) {
            final entrante = child.key == ValueKey<int>(index);
            if (!entrante) {
              return FadeTransition(opacity: animation, child: child);
            }
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(index),
            child: _pantalla(index),
          ),
        ),
        bottomNavigationBar: AppNavBar(
          selectedIndex: index,
          onSelected: (i) => tabActual.value = i,
        ),
      ),
    );
  }
}
