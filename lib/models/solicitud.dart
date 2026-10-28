/// Estados que maneja el backend en solicitudes_v2.estado.
class EstadoSolicitud {
  EstadoSolicitud._();

  static const String enEspera = 'en_espera';
  static const String enProceso = 'en_proceso';
  static const String atendida = 'atendida';

  /// Filtro especial del backend: en_espera + en_proceso.
  static const String pendientes = 'pendientes';
}

DateTime? _fecha(dynamic valor) =>
    valor is String ? DateTime.tryParse(valor)?.toLocal() : null;

/// Una fila de GET /api/solicitudes.
class Solicitud {
  final int id;

  /// Folio de seguimiento (ej. "462507"), identifica la solicitud en
  /// el historial y en las acciones del técnico.
  final String seguimiento;
  final String estado;
  final String? categoria;
  final String? subcategoria;
  final String? detalleTexto;
  final String? comentario;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final String? tecnico;

  Solicitud({
    required this.id,
    required this.seguimiento,
    required this.estado,
    this.categoria,
    this.subcategoria,
    this.detalleTexto,
    this.comentario,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.tecnico,
  });

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    final tecnico = [json['tecnico_nombre'], json['tecnico_apellido']]
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .join(' ');

    return Solicitud(
      id: json['id'] as int,
      seguimiento: (json['seguimiento'] ?? '') as String,
      estado: (json['estado'] ?? '') as String,
      categoria: json['categoria_nombre'] as String?,
      subcategoria: json['subcategoria_nombre'] as String?,
      detalleTexto: json['detalle_texto'] as String?,
      comentario: json['comentario'] as String?,
      fechaCreacion: _fecha(json['fecha_creacion']),
      fechaActualizacion: _fecha(json['fecha_actualizacion']),
      tecnico: tecnico.isEmpty ? null : tecnico,
    );
  }
}

/// Una fila de GET /api/solicitudes/:seguimiento/historial.
class CambioEstado {
  final String? estadoAnterior;
  final String estadoNuevo;
  final DateTime? fechaHora;
  final String? usuario;

  CambioEstado({
    required this.estadoAnterior,
    required this.estadoNuevo,
    required this.fechaHora,
    required this.usuario,
  });

  factory CambioEstado.fromJson(Map<String, dynamic> json) {
    return CambioEstado(
      estadoAnterior: json['estado_anterior'] as String?,
      estadoNuevo: (json['estado_nuevo'] ?? '') as String,
      fechaHora: _fecha(json['fecha_hora']),
      usuario: json['usuario_nombre'] as String?,
    );
  }
}
