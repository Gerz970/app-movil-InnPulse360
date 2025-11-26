import 'package:dio/dio.dart';
import '../../../api/api_config.dart';
import '../../../api/endpoints_transporte.dart';
import '../../../core/auth/services/session_storage.dart';

class TransporteService {
  final Dio _dio;
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  TransporteService({Dio? dio}) : _dio = dio ?? Dio() {
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

  Future<Response> fetchServicios() async {
    final token = await _getToken();
    if (token == null) throw Exception('No hay token de autenticación disponible');

    final url = baseUrl + EndpointsTransporte.list;
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await _dio.get(url, options: Options(headers: headers));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createServicio(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('No hay token de autenticación disponible');

    final url = baseUrl + EndpointsTransporte.list;
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await _dio.post(
        url,
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getServicioDetail(int idServicio) async {
    final token = await _getToken();
    if (token == null) throw Exception('No hay token de autenticación disponible');

    final url = baseUrl + EndpointsTransporte.detail(idServicio);
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await _dio.get(url, options: Options(headers: headers));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createServicioDesdeReservacion(
    Map<String, dynamic> data,
    int reservacionId,
  ) async {
    final token = await _getToken();
    if (token == null) throw Exception('No hay token de autenticación disponible');

    final url = baseUrl + EndpointsTransporte.list;
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: {'reservacion_id': reservacionId}, // Enviar como query parameter
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

