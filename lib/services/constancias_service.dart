import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../core/api_client.dart';
import '../core/api_config.dart';

/// Descarga y abre la Constancia de Soporte Técnico (PDF) de una
/// solicitud atendida: GET /api/constancias/:seguimiento/pdf.
class ConstanciasService {
  Dio get _dio => ApiClient.instance.dio;

  /// Descarga el PDF a la carpeta temporal de la app y lo abre con el
  /// visor de PDF del teléfono. Lanza [ApiException] si falla.
  Future<void> descargarYAbrir(String seguimiento) async {
    try {
      final response = await _dio.get<List<int>>(
        '${ApiConfig.constanciasEndpoint}/$seguimiento/pdf',
        options: Options(
          responseType: ResponseType.bytes,
          // Un PDF puede tardar más que un JSON en redes lentas.
          receiveTimeout: const Duration(seconds: 45),
        ),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw ApiException('El servidor devolvió un archivo vacío.');
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/constancia_$seguimiento.pdf');
      await file.writeAsBytes(bytes, flush: true);

      final result = await OpenFilex.open(file.path, type: 'application/pdf');
      if (result.type != ResultType.done) {
        throw ApiException(
          'No se encontró una aplicación para abrir PDF en este teléfono.',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ApiException(
          'Esta solicitud aún no tiene constancia.',
          statusCode: 404,
        );
      }
      throw ApiException.fromDio(e);
    }
  }
}
