import '../core/api_client.dart';

/// Convierte cualquier error en un mensaje listo para mostrar al usuario.
String mensajeDe(Object? e) {
  if (e is ApiException) return e.message;
  return 'Ocurrió un error inesperado. Intenta nuevamente.';
}
