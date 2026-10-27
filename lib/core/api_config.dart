/// Configuración central de acceso a la API existente de SISSTe v3.8.
///
/// El backend Node.js ya está desplegado en el servidor 172.17.102.202
/// detrás de un Proxy Inverso Apache (ver Fase de Diseño, sección 4).
/// SISSTeApp NO define endpoints nuevos en este Sprint: reutiliza el
/// endpoint de autenticación ya existente para la versión web.
///
/// Si en tu backend el endpoint tiene otro nombre o puerto, este es
/// el ÚNICO archivo que necesitas tocar.
class ApiConfig {
  ApiConfig._();

  /// IP real del servidor SISSTe dentro de la red de la SUNDDE.
  ///
  /// Cambia esto según el entorno:
  /// - Prueba en emulador Android -> usa 10.0.2.2 en vez de localhost.
  /// - Prueba en dispositivo físico dentro de la red SUNDDE -> IP real.
  /// - Producción -> dominio o IP detrás de Apache con TLS habilitado.
  static const String baseUrl = 'http://172.17.102.202';

  static const String loginEndpoint = '/api/login';

  /// Timeouts pensados para redes lentas (3G) en vez de valores por
  /// defecto agresivos. Ver conversación sobre optimización en 3G:
  /// mejor esperar un poco más que fallar de inmediato en una red
  /// congestionada, pero sin dejar la app "colgada" indefinidamente.
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
