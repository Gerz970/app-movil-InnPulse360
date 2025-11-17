import 'package:dio/dio.dart'; // se importa libreria para hacer peticiones HTTP al backend
import '../../../api/api_config.dart'; // importar configuracion del api
import '../../../api/endpoints_piso.dart'; // importar endpoints de hoteles
import '../../../core/auth/services/session_storage.dart'; // para obtener token de sesión

class PisoService {
  final Dio _dio;

  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  PisoService({Dio? dio}): _dio = dio ?? Dio(){
    _dio.options.connectTimeout = Duration(seconds: ApiConfig.connectTimeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: ApiConfig.receiveTimeoutSeconds);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
  }

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

  Future<Response> fetchHotels({int skip = 0, int limit = 100}) async {
    // Obtener token de la sesión
    final token = await _getToken();
    
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    // Construir la URL con query parameters
    final url = baseUrl + EndpointsPiso.getByHotel(1);

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición GET
    try {
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }
}