import 'package:flutter/material.dart';

import '../core/secure_session.dart';
import '../widgets/action_list_item.dart';
import '../widgets/transiciones.dart';
import 'crear_solicitud_screen.dart';

/// Home del usuario estándar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nombre = '';

  @override
  void initState() {
    super.initState();
    SecureSession.instance.readNombre().then((n) {
      if (mounted) setState(() => _nombre = n ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _nombre.isEmpty ? 'Bienvenido' : 'Hola, $_nombre',
          style: t.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          '¿Tienes una falla o necesitas soporte técnico?',
          style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        ActionListItem.onPrimaryContainer(
          context,
          leadingIcon: Icons.inbox_rounded,
          title: 'Crear Nueva Solicitud',
          subtitle: 'Reporta una falla al equipo de soporte',
          onTap: () => Navigator.of(context)
              .push(slideRoute(const CrearSolicitudScreen())),
        ),
      ],
    );
  }
}
