import 'package:flutter/material.dart';

/// Efecto de "presión": el hijo se encoge ligeramente mientras el dedo
/// está sobre él y vuelve con un pequeño rebote. Se combina con el
/// ripple propio de cada botón o ítem (no lo reemplaza).
///
/// Usa un Listener, así que no interfiere con los gestos del hijo.
class PressScale extends StatefulWidget {
  final Widget child;
  final double scale;
  final bool enabled;

  const PressScale({
    super.key,
    required this.child,
    this.scale = 0.97,
    this.enabled = true,
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _set(bool v) {
    if (!widget.enabled || _down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
