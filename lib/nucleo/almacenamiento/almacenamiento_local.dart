import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de almacenamiento local
/// Maneja el almacenamiento seguro de tokens y datos de usuario
class AlmacenamientoLocal {
  /// Almacenamiento seguro para datos sensibles (tokens)
  final FlutterSecureStorage _almacenamientoSeguro = const FlutterSecureStorage();
  
  /// Keys para almacenar datos
  static const String _keyToken = 'access_token';
  static const String _keyTokenType = 'token_type';
  static const String _keyExpiresIn = 'expires_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserLogin = 'user_login';
  static const String _keyUserEmail = 'user_email';
  
  /// Guardar token de acceso de forma segura
  Future<void> guardarToken(String token) async {
    await _almacenamientoSeguro.write(key: _keyToken, value: token);
  }
  
  /// Obtener token de acceso
  Future<String?> obtenerToken() async {
    return await _almacenamientoSeguro.read(key: _keyToken);
  }
  
  /// Guardar tipo de token (normalmente "bearer")
  Future<void> guardarTipoToken(String tipoToken) async {
    await _almacenamientoSeguro.write(key: _keyTokenType, value: tipoToken);
  }
  
  /// Obtener tipo de token
  Future<String?> obtenerTipoToken() async {
    return await _almacenamientoSeguro.read(key: _keyTokenType);
  }
  
  /// Guardar tiempo de expiración del token
  Future<void> guardarExpiracion(int expiresIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyExpiresIn, expiresIn);
  }
  
  /// Obtener tiempo de expiración del token
  Future<int?> obtenerExpiracion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyExpiresIn);
  }
  
  /// Guardar información del usuario
  Future<void> guardarInformacionUsuario({
    required int idUsuario,
    required String login,
    required String correoElectronico,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, idUsuario);
    await prefs.setString(_keyUserLogin, login);
    await prefs.setString(_keyUserEmail, correoElectronico);
  }
  
  /// Obtener ID del usuario
  Future<int?> obtenerIdUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }
  
  /// Obtener login del usuario
  Future<String?> obtenerLoginUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserLogin);
  }
  
  /// Obtener correo del usuario
  Future<String?> obtenerCorreoUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }
  
  /// Verificar si el usuario está autenticado
  /// Retorna true si existe un token guardado
  Future<bool> estaAutenticado() async {
    final token = await obtenerToken();
    return token != null && token.isNotEmpty;
  }
  
  /// Limpiar todos los datos almacenados (logout)
  Future<void> limpiarDatos() async {
    await _almacenamientoSeguro.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

