import 'package:dio/dio.dart';
import '../../../api/api_config.dart';
import '../../../api/endpoints_tipo_limpieza.dart';
import '../../../core/auth/services/session_storage.dart';

class TipoLimpiezaService {
  final Dio _dio;
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  TipoLimpiezaService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = Duration(seconds: ApiConfig.connectTimeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: ApiConfig.receiveTimeoutSeconds);
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

      final token = session['token'] ??
                   session['access_token'] ??
                   session['accessToken'] ??
                   session['token_access'];

      return token is String ? token : null;
    } catch (e) {
      print('Error al obtener token: $e');
      return null;
    }
  }

  /// Método para obtener el listado de tipos de limpieza
  /// Requiere token de autenticación en el header
  Future<Response> fetchTiposLimpieza() async {
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsTipoLimpieza.list;
    final headers = {
      'Authorization': 'Bearer $token',
    };

    print('🔍 [TipoLimpiezaService] Llamando a: $url');
    print('🔍 [TipoLimpiezaService] Headers: ${headers.keys}');

    try {
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      );

      print('✅ [TipoLimpiezaService] Respuesta recibida:');
      print('   Status Code: ${response.statusCode}');
      print('   Data Type: ${response.data.runtimeType}');
      print('   Data: ${response.data}');
      
      return response;
    } catch (e) {
      print('❌ [TipoLimpiezaService] Error: $e');
      if (e is DioException) {
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Request Path: ${e.requestOptions.path}');
      }
      rethrow;
    }
  }
}

