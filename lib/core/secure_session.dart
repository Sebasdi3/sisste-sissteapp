import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Maneja el ciclo de vida de la sesión local del usuario.
///
/// El backend de SISSTe no emite JWT (autenticación heredada de la
/// versión web, basada en sesión/cookie del lado servidor). Este
/// Sprint guarda userId/nombre/rol como marcador de sesión activa en
/// el dispositivo (RNF-APP-01). Validar la sesión contra el servidor
/// en cada request queda en Backlog.
class SecureSession {
  SecureSession._();
  static final SecureSession instance = SecureSession._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _userIdKey = 'user_id';
  static const _nameKey = 'user_nombre';
  static const _roleKey = 'user_rol';

  Future<void> saveSession({
    required int userId,
    required String nombre,
    required String rol,
  }) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
    await _storage.write(key: _nameKey, value: nombre);
    await _storage.write(key: _roleKey, value: rol);
  }

  Future<String?> readUserId() => _storage.read(key: _userIdKey);
  Future<String?> readNombre() => _storage.read(key: _nameKey);
  Future<String?> readRol() => _storage.read(key: _roleKey);

  Future<bool> hasActiveSession() async {
    final id = await readUserId();
    return id != null && id.isNotEmpty;
  }

  Future<void> clear() => _storage.deleteAll();
}