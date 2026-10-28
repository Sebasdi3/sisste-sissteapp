import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Maneja el ciclo de vida de la sesión local del usuario.
///
/// El backend de SISSTe no emite JWT (autenticación por sesión/cookie
/// del lado servidor). Aquí se guarda userId/nombre/rol como marcador
/// de sesión activa en el dispositivo (RNF-APP-01), más la preferencia
/// "Mantener sesión activa en el dispositivo" elegida al iniciar sesión.
class SecureSession {
  SecureSession._();
  static final SecureSession instance = SecureSession._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _userIdKey = 'user_id';
  static const _nameKey = 'user_nombre';
  static const _roleKey = 'user_rol';
  static const _keepKey = 'keep_session';

  Future<void> saveSession({
    required int userId,
    required String nombre,
    required String rol,
  }) async {
    await _storage.write(key: _userIdKey, value: userId.toString());
    await _storage.write(key: _nameKey, value: nombre);
    await _storage.write(key: _roleKey, value: rol);
  }

  Future<void> saveKeepSession(bool keep) =>
      _storage.write(key: _keepKey, value: keep ? '1' : '0');

  Future<String?> readUserId() => _storage.read(key: _userIdKey);
  Future<String?> readNombre() => _storage.read(key: _nameKey);
  Future<String?> readRol() => _storage.read(key: _roleKey);

  /// Si no se guardó la preferencia (sesiones anteriores), se asume que
  /// el usuario sí quería mantener la sesión.
  Future<bool> readKeepSession() async =>
      (await _storage.read(key: _keepKey)) != '0';

  Future<bool> hasActiveSession() async {
    final id = await readUserId();
    return id != null && id.isNotEmpty;
  }

  Future<void> clear() => _storage.deleteAll();
}
