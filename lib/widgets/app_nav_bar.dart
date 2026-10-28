import 'package:flutter/material.dart';

/// Los 4 destinos de la barra inferior, en el orden de la app.
class Destinos {
  Destinos._();
  static const int home = 0;
  static const int pendientes = 1;
  static const int historial = 2;
  static const int ajustes = 3;
}

/// Barra de navegación inferior compartida por todas las pantallas
/// principales. 80 dp de alto sobre surfaceContainer, con el indicador
/// en forma de píldora y el ícono relleno en el destino activo.
class AppNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AppNavBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_rounded),
          selectedIcon: Icon(Icons.menu_rounded),
          label: 'Sol. Pendientes',
        ),
        NavigationDestination(
          icon: Icon(Icons.schedule_rounded),
          selectedIcon: Icon(Icons.schedule_rounded),
          label: 'Historial',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings_rounded),
          label: 'Ajustes',
        ),
      ],
    );
  }
}
