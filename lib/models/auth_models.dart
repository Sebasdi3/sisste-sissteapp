/// Respuesta esperada del endpoint POST /api/login.
///
/// El backend NO usa JWT: es autenticación basada en sesión/cookie,
/// heredada de la versión web. La app usa userId como identificador
/// de sesión local (ver SecureSession).
class LoginResponse {
  final int userId;
  final String nombre;
  final String rol; // 'operativo' | 'tecnico' | 'admin'

  LoginResponse({required this.userId, required this.nombre, required this.rol});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json['userId'] as int,
      nombre: (json['nombre'] ?? '') as String,
      rol: (json['rol'] ?? 'operativo') as String,
    );
  }
}

enum AuthFailureType { credencialesInvalidas, sinConexion, servidorNoDisponible, desconocido }

class AuthResult {
  final bool success;
  final LoginResponse? data;
  final AuthFailureType? failureType;
  final String? message;

  AuthResult.success(this.data)
      : success = true,
        failureType = null,
        message = null;

  AuthResult.failure(this.failureType, this.message)
      : success = false,
        data = null;
}