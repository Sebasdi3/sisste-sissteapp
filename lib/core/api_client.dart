import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'api_config.dart';
import 'secure_session.dart';

/// Cliente HTTP único de la app.
///
/// El backend autentica con sesión de servidor (cookie `connect.sid`),
/// así que TODAS las peticiones deben compartir el mismo Dio y el
/// mismo cookie jar: si cada servicio creara su propio Dio, el login
/// funcionaría pero la siguiente petición llegaría sin cookie y el
/// servidor respondería 401.
///
/// Hay que llamar a [init] una vez, antes de runApp (ver main.dart).
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late final Dio dio;
  late final PersistCookieJar _cookieJar;
  bool _initialized = false;

  /// Se invoca cuando el servidor responde 401 a una petición que no es
  /// el login (sesión vencida a las 8 h, o servidor reiniciado). main.dart
  /// lo usa para mandar al usuario a la pantalla de login.
  void Function()? onSessionExpired;

  Future<void> init() async {
    if (_initialized) return;

    // Carpeta privada de la app: ninguna otra app puede leerla.
    final dir = await getApplicationSupportDirectory();
    _cookieJar = PersistCookieJar(
      storage: FileStorage('${dir.path}/.cookies/'),
    );

    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(CookieManager(_cookieJar));
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          final esLogin = e.requestOptions.path == ApiConfig.loginEndpoint;
          if (e.response?.statusCode == 401 && !esLogin) {
            // Solo avisa la primera vez: tras limpiar, ya no hay sesión
            // local y las peticiones paralelas que fallen no repiten el aviso.
            final habiaSesion = await SecureSession.instance.hasActiveSession();
            if (habiaSesion) {
              await SecureSession.instance.clear();
              await _cookieJar.deleteAll();
              onSessionExpired?.call();
            }
          }
          handler.next(e);
        },
      ),
    );

    _initialized = true;
  }

  /// Borra la cookie de sesión guardada en el dispositivo.
  Future<void> clearCookies() => _cookieJar.deleteAll();
}

/// Error de API ya traducido a un mensaje que se puede mostrar al usuario.
class ApiException implements Exception {
  final String message;
  final bool sinConexion;
  final int? statusCode;

  ApiException(this.message, {this.sinConexion = false, this.statusCode});

  factory ApiException.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return ApiException(
          'No se pudo conectar con el servidor. Verifica tu conexión '
          'a la red interna e intenta de nuevo.',
          sinConexion: true,
        );
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final data = e.response?.data;
        final mensajeServidor =
            data is Map<String, dynamic> && data['message'] is String
                ? data['message'] as String
                : null;
        if (status == 401) {
          return ApiException(
            'Tu sesión venció. Inicia sesión nuevamente.',
            statusCode: status,
          );
        }
        if (status == 403) {
          return ApiException(
            'No tienes permiso para realizar esta acción.',
            statusCode: status,
          );
        }
        return ApiException(
          mensajeServidor ?? 'El servidor no está disponible en este momento.',
          statusCode: status,
        );
      default:
        return ApiException('Ocurrió un error inesperado. Intenta nuevamente.');
    }
  }

  @override
  String toString() => message;
}
