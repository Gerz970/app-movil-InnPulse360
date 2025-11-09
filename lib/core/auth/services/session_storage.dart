import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para manejar el almacenamiento de la sesión del usuario
/// Guarda y recupera la sesión usando SharedPreferences
class SessionStorage {
  static const String _sessionKey = 'user_session';

  /// Guardar la sesión del usuario
  /// Convierte el Map a JSON string y lo guarda en SharedPreferences
  static Future<bool> saveSession(Map<String, dynamic> sessionData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = jsonEncode(sessionData);
      return await prefs.setString(_sessionKey, sessionJson);
    } catch (e) {
      print('Error al guardar sesión: $e');
      return false;
    }
  }

  /// Obtener la sesión guardada del usuario
  /// Retorna null si no hay sesión guardada o si hay un error
  static Future<Map<String, dynamic>?> getSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      
      if (sessionJson == null) {
        return null;
      }
      
      final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
      return sessionData;
    } catch (e) {
      print('Error al obtener sesión: $e');
      return null;
    }
  }

  /// Limpiar la sesión guardada
  /// Útil para logout
  static Future<bool> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_sessionKey);
    } catch (e) {
      print('Error al limpiar sesión: $e');
      return false;
    }
  }

  /// Verificar si hay una sesión activa
  /// Retorna true si existe una sesión guardada
  static Future<bool> isSessionActive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_sessionKey);
    } catch (e) {
      print('Error al verificar sesión: $e');
      return false;
    }
  }
}

