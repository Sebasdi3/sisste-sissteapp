import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_config.dart';
import '../core/secure_session.dart';
import '../models/auth_models.dart';

/// Consume los endpoints de autenticación del backend Node.js
/// (POST /api/login, POST /api/logout, GET /api/session). No crea
/// rutas nuevas en el servidor: solo las consume desde el móvil.
class AuthService {
  Dio get _dio => ApiClient.instance.dio;

  Future<AuthResult> login({
    required String cedula,
    required String password,
    bool keepSession = true,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: {'cedula': cedula, 'password': password},
      );

      final body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      if (body['success'] != true) {
        return AuthResult.failure(
          AuthFailureType.credencialesInvalidas,
          'Cédula o contraseña incorrecta.',
        );
      }

      final login = LoginResponse.fromJson(body);

      // La cookie de sesión ya quedó guardada por el cookie jar; esto
      // solo deja el marcador local para pintar el nombre y el rol.
      await SecureSession.instance.saveSession(
        userId: login.userId,
        nombre: login.nombre,
        rol: login.rol,
      );
      await SecureSession.instance.saveKeepSession(keepSession);

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

  /// Pregunta al servidor (GET /api/session) si la cookie guardada sigue
  /// siendo una sesión válida. Si lo es, refresca el marcador local con
  /// los datos que devuelve el servidor.
  Future<SessionStatus> checkSession() async {
    try {
      final response = await _dio.get(ApiConfig.sessionEndpoint);
      final body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      if (body['success'] == true && body['userId'] is int) {
        await SecureSession.instance.saveSession(
          userId: body['userId'] as int,
          nombre: (body['nombre'] ?? '') as String,
          rol: (body['rol'] ?? 'usuario') as String,
        );
        return SessionStatus.active;
      }
      return SessionStatus.expired;
    } catch (_) {
      return SessionStatus.unreachable;
    }
  }

  /// PUT /api/cambiar-password — cambia la contraseña del usuario con
  /// sesión activa. Lanza [ApiException] con mensaje listo para mostrar.
  Future<void> cambiarPassword(String passwordNueva) async {
    try {
      await _dio.put(
        ApiConfig.changePasswordEndpoint,
        data: {'passwordNueva': passwordNueva},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Cierra la sesión en el servidor (queda registrado en la auditoría)
  /// y borra todo rastro local. Si no hay red, igual limpia el
  /// dispositivo: el usuario no debe quedar atrapado en la app.
  Future<void> logout() async {
    try {
      await _dio.post(ApiConfig.logoutEndpoint);
    } catch (_) {
      // Sin red o servidor caído: se limpia localmente de todas formas.
    }
    await clearLocalSession();
  }

  /// Borra marcador local y cookie sin hablar con el servidor.
  Future<void> clearLocalSession() async {
    await SecureSession.instance.clear();
    await ApiClient.instance.clearCookies();
  }

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
            'a la red interna e intenta de nuevo.';
      case AuthFailureType.credencialesInvalidas:
        return 'Cédula o contraseña incorrecta.';
      case AuthFailureType.servidorNoDisponible:
        return 'El servidor no está disponible en este momento. Intenta '
            'más tarde.';
      case AuthFailureType.desconocido:
        return 'Ocurrió un error inesperado. Intenta nuevamente.';
    }
  }
}
