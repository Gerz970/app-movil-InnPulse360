import 'package:dio/dio.dart';
import '../models/piso_model.dart';
import '../../../api/endpoints_piso.dart'; // importar endpoints de hoteles
import '../../../api/api_config.dart'; // importar configuracion del api
import '../../../core/auth/services/session_storage.dart'; // para obtener token de sesión

class PisoService {
  final Dio _dio;
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  PisoService({Dio? dio}) : _dio = dio ?? Dio() {
    // configuración para la petición
    _dio.options.connectTimeout = Duration(seconds: ApiConfig.connectTimeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: ApiConfig.receiveTimeoutSeconds);
    _dio.options.headers = {
      // son valores de configuracion del endpoint
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Obtener el token de la sesión guardada
  Future<String?> _getToken() async {
    try {
      final session = await SessionStorage.getSession();
      if (session == null) return null;

      // Intentar obtener el token desde diferentes posibles campos
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

  Future<List<Piso>> getPisosByHotel(int idHotel) async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    // Construir la URL con query parameters
    final url = baseUrl + EndpointsPiso.getByHotel(idHotel);
    final headers = {
      'Authorization': 'Bearer $token',
    };
    try{
      final response = await _dio.get(url, options: Options(headers: headers));
      return (response.data as List)
        .map((json) => Piso.fromJson(json))
        .toList();    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  Future<Piso> createPiso(PisoCreateModel model) async {
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final headers = {
      'Authorization': 'Bearer $token',
    };

    try{
      final response = await _dio.post(
        baseUrl + EndpointsPiso.pisos,
        data: model.toJson(),
        options: Options(headers: headers),
      );
      
      return Piso.fromJson(response.data);
    } catch (e) {
      // Manejo de errores
        rethrow;
      }
    }
    

  // Future<Piso> updatePiso(int idPiso, PisoUpdateModel model) async {
  //   final response = await _dio.put(
  //     "$baseUrl/pisos/$idPiso",
  //     data: model.toJson(),
  //   );

  //   return Piso.fromJson(response.data);
  // }

  // Future<bool> deletePiso(int idPiso) async {
  //   await _dio.delete("$baseUrl/pisos/$idPiso");
  //   return true;
  // }
}
