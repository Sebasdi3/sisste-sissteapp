/// Configuración central de acceso a la API de SISSTe (SIGESOT).
///
/// El backend Node.js corre en el contenedor 172.17.102.191 y escucha
/// directamente en el puerto 3000 (PORT del .env del servidor), sin
/// proxy inverso de por medio. La autenticación es por sesión/cookie
/// (express-session), no por JWT: la app guarda la cookie `connect.sid`
/// con un cookie jar persistente (ver api_client.dart).
///
/// Si el backend cambia de IP, de puerto o pasa a estar detrás de un
/// proxy con TLS, este es el ÚNICO archivo de Dart que hay que tocar
/// (más network_security_config.xml, que debe listar la misma IP).
class ApiConfig {
  ApiConfig._();

  /// - Dispositivo físico dentro de la red interna -> IP real del contenedor.
  /// - Emulador Android -> el emulador no ve la LAN igual que el
  ///   teléfono; usa la IP real si la red lo permite o 10.0.2.2 si
  ///   corres el backend en tu propia PC.
  static const String baseUrl = 'http://172.17.102.191:3000';

  // Autenticación
  static const String loginEndpoint = '/api/login';
  static const String logoutEndpoint = '/api/logout';
  static const String sessionEndpoint = '/api/session';
  static const String changePasswordEndpoint = '/api/cambiar-password';

  // Solicitudes de soporte
  static const String categoriasEndpoint = '/api/categorias';
  static const String solicitudesEndpoint = '/api/solicitudes';
  static const String constanciasEndpoint = '/api/constancias';

  /// Timeouts pensados para redes lentas (3G) en vez de valores por
  /// defecto agresivos: mejor esperar un poco más que fallar de
  /// inmediato en una red congestionada, pero sin dejar la app
  /// "colgada" indefinidamente.
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
