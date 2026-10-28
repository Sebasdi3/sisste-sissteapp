/// Respuesta del endpoint POST /api/login.
///
/// El backend NO usa JWT: es autenticación por sesión/cookie. La app
/// guarda userId/nombre/rol como marcador local de sesión (ver
/// SecureSession) y la cookie en el cookie jar (ver ApiClient).
class LoginResponse {
  final int userId;
  final String nombre;

  /// Roles núcleo del backend: 'usuario' | 'tecnico' | 'admin'.
  /// También puede ser la clave de un rol personalizado creado por el
  /// administrador (con permisos propios en el servidor).
  final String rol;

  /// true si el usuario debe cambiar su contraseña en el primer inicio
  /// de sesión (la versión web lo obliga; la app aún no tiene esa
  /// pantalla — usa PUT /api/cambiar-password).
  final bool debeCambiarPassword;

  LoginResponse({
    required this.userId,
    required this.nombre,
    required this.rol,
    this.debeCambiarPassword = false,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      userId: json['userId'] as int,
      nombre: (json['nombre'] ?? '') as String,
      rol: (json['rol'] ?? 'usuario') as String,
      debeCambiarPassword: json['debeCambiarPassword'] == true,
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

/// Resultado de preguntarle al servidor si la sesión sigue activa.
enum SessionStatus {
  /// El servidor reconoce la sesión.
  active,

  /// El servidor respondió y la sesión ya no existe (venció o se reinició).
  expired,

  /// No se pudo consultar (sin red, servidor caído).
  unreachable,
}
