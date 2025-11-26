import 'package:dio/dio.dart';
import '../../../api/api_config.dart';
import '../../../core/auth/services/session_storage.dart';

class ChatService {
  final Dio _dio;

  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  ChatService({Dio? dio}) : _dio = dio ?? Dio() {
    // Configuración para la petición
    _dio.options.connectTimeout = Duration(
      seconds: ApiConfig.connectTimeoutSeconds,
    );
    _dio.options.receiveTimeout = Duration(
      seconds: ApiConfig.receiveTimeoutSeconds,
    );
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Obtener el token de la sesión guardada
  Future<String?> _getToken() async {
    try {
      final session = await SessionStorage.getSession();
      if (session == null) return null;

      final token =
          session['token'] ??
          session['access_token'] ??
          session['accessToken'] ??
          session['token_access'];

      return token is String ? token : null;
    } catch (e) {
      print('Error al obtener token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> enviarMensaje(String mensaje) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final response = await _dio.post(
        '${baseUrl}chat/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'message': mensaje,
        },
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Error al enviar mensaje: $e');
      rethrow;
    }
  }

  Future<void> limpiarHistorial() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      await _dio.post(
        '${baseUrl}chat/limpiar',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('Error al limpiar historial: $e');
      rethrow;
    }
  }
}

