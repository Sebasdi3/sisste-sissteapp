import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/categoria.dart';

/// GET /api/categorias — cualquier usuario con sesión activa.
class CategoriasService {
  Dio get _dio => ApiClient.instance.dio;

  /// Lanza [ApiException] con un mensaje listo para mostrar si falla.
  Future<List<Categoria>> listar() async {
    try {
      final response = await _dio.get(ApiConfig.categoriasEndpoint);
      final body = response.data as Map<String, dynamic>;
      return (body['data'] as List<dynamic>)
          .map((c) => Categoria.fromJson(c as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
