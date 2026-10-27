import 'package:dio/dio.dart';

import '../core/api_config.dart';
import '../core/secure_session.dart';
import '../models/auth_models.dart';

/// Consume el endpoint de autenticación YA EXISTENTE en el backend
/// Node.js (US-APP-01 / RF-APP-01). No crea rutas nuevas en el
/// servidor: solo las consume desde el cliente móvil.
class AuthService {
  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  late final Dio _dio;

Future<AuthResult> login({required String cedula, required String password}) async {
  try {
    final response = await _dio.post(
      ApiConfig.loginEndpoint,
      data: {'cedula': cedula, 'password': password},
    );

    final body = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : <String, dynamic>{};

    // El backend responde 200 incluso con éxito=false en algunos
    // casos; hay que revisar el flag explícitamente.
    if (body['success'] != true) {
      return AuthResult.failure(
        AuthFailureType.credencialesInvalidas,
        'Cédula o contraseña incorrecta.',
      );
    }

    final login = LoginResponse.fromJson(body);

    await SecureSession.instance.saveSession(
      userId: login.userId,
      nombre: login.nombre,
      rol: login.rol,
    );

    return AuthResult.success(login);
  } on DioException catch (e) {
    return AuthResult.failure(_mapFailureType(e), _mapFriendlyMessage(e));
  } catch (_) {
    return AuthResult.failure(
      AuthFailureType.desconocido,
      'Ocurrió un error inesperado. Intenta nuevamente.',
    );
  }
}

  Future<void> logout() => SecureSession.instance.clear();

  /// Clasifica el tipo de fallo. Distinguir "sin conexión" de
  /// "credenciales inválidas" es exactamente lo que pide RNF-APP-04:
  /// un mensaje amigable ante pérdida de conectividad, en lugar de
  /// un cierre abrupto o un error genérico confuso.
  AuthFailureType _mapFailureType(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return AuthFailureType.sinConexion;
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        if (status == 401 || status == 403) {
          return AuthFailureType.credencialesInvalidas;
        }
        return AuthFailureType.servidorNoDisponible;
      default:
        return AuthFailureType.desconocido;
    }
  }

  String _mapFriendlyMessage(DioException e) {
    switch (_mapFailureType(e)) {
      case AuthFailureType.sinConexion:
        return 'No se pudo conectar con el servidor. Verifica tu conexión '
            'a la red de la SUNDDE e intenta de nuevo.';
      case AuthFailureType.credencialesInvalidas:
        return 'Cédula o contraseña incorrecta.';
      case AuthFailureType.servidorNoDisponible:
        return 'El servidor no está disponible en este momento. Intenta '
            'más tarde.';
      case AuthFailureType.desconocido:
      default:
        return 'Ocurrió un error inesperado. Intenta nuevamente.';
    }
  }
}
