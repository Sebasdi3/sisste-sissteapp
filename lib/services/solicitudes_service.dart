import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_config.dart';
import '../core/secure_session.dart';
import '../models/solicitud.dart';

/// Endpoints de solicitudes del backend. Todos lanzan [ApiException]
/// con un mensaje listo para mostrar al usuario si algo falla.
class SolicitudesService {
  Dio get _dio => ApiClient.instance.dio;

  /// POST /api/solicitudes — crea una solicitud y devuelve su folio de
  /// seguimiento. El solicitante sale de la sesión del servidor, no se
  /// envía desde la app.
  Future<String> crear({
    required int categoriaId,
    int? subcategoriaId,
    String? detalleTexto,
    String? comentario,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.solicitudesEndpoint,
        data: {
          'categoriaId': categoriaId,
          if (subcategoriaId != null) 'subcategoriaId': subcategoriaId,
          if (detalleTexto != null && detalleTexto.isNotEmpty)
            'detalleTexto': detalleTexto,
          if (comentario != null && comentario.isNotEmpty)
            'comentario': comentario,
        },
      );
      final body = response.data as Map<String, dynamic>;
      return body['seguimiento'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /api/solicitudes — solicitudes del usuario que inició sesión.
  ///
  /// [estado]: 'pendientes' (en espera + en proceso), 'en_espera',
  /// 'en_proceso', 'atendida' o 'todas' (ver [EstadoSolicitud]).
  ///
  /// Siempre filtra por el userId de la sesión. OJO: hoy el servidor
  /// NO obliga ese filtro (un usuario estándar podría pedir las de
  /// todos si omite userId), así que la app nunca debe omitirlo.
  Future<List<Solicitud>> listarMias({
    String estado = 'todas',
    int pagina = 1,
    int limite = 50,
  }) async {
    final userId = await SecureSession.instance.readUserId();
    if (userId == null) {
      throw ApiException('Tu sesión venció. Inicia sesión nuevamente.');
    }

    try {
      final response = await _dio.get(
        ApiConfig.solicitudesEndpoint,
        queryParameters: {
          'userId': userId,
          'estado': estado,
          'pagina': pagina,
          'limite': limite,
        },
      );
      final body = response.data as Map<String, dynamic>;
      return (body['data'] as List<dynamic>)
          .map((s) => Solicitud.fromJson(s as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /api/solicitudes/:seguimiento/historial — línea de tiempo de
  /// cambios de estado, de la más antigua a la más reciente.
  Future<List<CambioEstado>> historial(String seguimiento) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.solicitudesEndpoint}/$seguimiento/historial',
      );
      final body = response.data as Map<String, dynamic>;
      return (body['data'] as List<dynamic>)
          .map((c) => CambioEstado.fromJson(c as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
