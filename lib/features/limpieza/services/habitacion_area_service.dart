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
}

