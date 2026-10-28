import 'package:flutter/material.dart';

import '../widgets/app_nav_bar.dart';
import '../widgets/press_scale.dart';
import 'main_shell.dart';

/// Confirmación de que la solicitud llegó al servidor, con su número
/// de seguimiento (folio).
class SolicitudEnviadaScreen extends StatelessWidget {
  final String seguimiento;
  const SolicitudEnviadaScreen({super.key, required this.seguimiento});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 220),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: c.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 40, color: c.primary),
                    const SizedBox(height: 12),
                    Text('Solicitud enviada', style: t.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      'Número de solicitud',
                      style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
                    ),
                    Text(
                      '#$seguimiento',
                      style: t.headlineMedium?.copyWith(color: c.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Puedes seguirla en Sol. Pendientes.',
                      style: t.bodyMedium?.copyWith(color: c.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PressScale(
                        child: FilledButton.tonalIcon(
                          onPressed: () => irATab(context, Destinos.home),
                          icon: const Icon(Icons.home_rounded),
                          label: const Text('Inicio'),
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
