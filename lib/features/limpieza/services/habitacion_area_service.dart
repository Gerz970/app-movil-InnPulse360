import 'package:dio/dio.dart';
import '../../../api/api_config.dart';
import '../../../api/endpoints_habitacion_area.dart';
import '../../../core/auth/services/session_storage.dart';

class HabitacionAreaService {
  final Dio _dio;
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  HabitacionAreaService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = Duration(seconds: ApiConfig.connectTimeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: ApiConfig.receiveTimeoutSeconds);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

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

  Future<Response> fetchHabitacionesDisponiblesPorPiso(int pisoId) async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsHabitacionArea.disponiblesPorPiso(pisoId);
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await _dio.get(url, options: Options(headers: headers));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Método para obtener habitaciones con estado (reservaciones y limpiezas)
  /// Requiere token de autenticación en el header
  /// Parámetro: pisoId del piso del cual obtener habitaciones con estado
  Future<Response> fetchHabitacionesConEstadoPorPiso(int pisoId) async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + 'habitacion-area/con-estado/$pisoId';
    final headers = {'Authorization': 'Bearer $token'};

    print('🔍 [HabitacionAreaService] Llamando a: $url');
    print('🔍 [HabitacionAreaService] Piso ID: $pisoId');
    print('🔍 [HabitacionAreaService] Headers: ${headers.keys}');

    try {
      final response = await _dio.get(url, options: Options(headers: headers));
      
      print('✅ [HabitacionAreaService] Respuesta recibida:');
      print('   Status Code: ${response.statusCode}');
      print('   Data Type: ${response.data.runtimeType}');
      print('   Data Length: ${response.data is List ? (response.data as List).length : 'N/A'}');
      if (response.data is List && (response.data as List).isNotEmpty) {
        print('   Primer elemento: ${(response.data as List).first}');
      }
      
      return response;
    } catch (e) {
      print('❌ [HabitacionAreaService] Error: $e');
      if (e is DioException) {
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Request Path: ${e.requestOptions.path}');
      }
      rethrow;
    }
  }
}

