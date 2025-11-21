import 'package:dio/dio.dart'; // se importa libreria para hacer peticiones HTTP al backend
import '../../../api/api_config.dart'; // importar configuracion del api
import '../../../api/endpoints_limpieza.dart'; // importar endpoints de limpieza
import '../../../core/auth/services/session_storage.dart'; // para obtener token de sesión

class LimpiezaService {
  //se instancia la clase de DIO para las peticiones de HTTP
  final Dio _dio;

  //URL base de la API
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  // Constructor de la clase, se inicializa validando si se proporciona una instancia del mismo objeto
  // en caso de que no se proporcione, este creara una nueva
  LimpiezaService({Dio? dio}) : _dio = dio ?? Dio() {
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

  /// Método para obtener el listado de limpiezas por estatus
  /// Requiere token de autenticación en el header
  /// Parámetro: estatusLimpiezaId del estatus a filtrar
  Future<Response> fetchLimpiezasPorEstatus(int estatusLimpiezaId) async {
    // Obtener token de la sesión
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    // Construir la URL
    final url = baseUrl + EndpointsLimpieza.estatus(estatusLimpiezaId);

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

  /// Método para actualizar una limpieza
  /// Requiere token de autenticación en el header
  /// Parámetros: limpiezaId de la limpieza a actualizar y Map con los datos a actualizar
  Future<Response> updateLimpieza(int limpiezaId, Map<String, dynamic> data) async {
    // Obtener token de la sesión
    final token = await _getToken();

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    // Construir la URL
    final url = baseUrl + EndpointsLimpieza.detail(limpiezaId);

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición PUT
    try {
      final response = await _dio.put(
        url,
        data: data,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para crear una nueva limpieza
  /// Requiere token de autenticación en el header
  /// Parámetro: Map con los datos de la limpieza a crear
  Future<Response> crearLimpieza(Map<String, dynamic> limpiezaData) async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsLimpieza.list;
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await _dio.post(
        url,
        data: limpiezaData,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Método para crear múltiples limpiezas en una sola petición
  /// Requiere token de autenticación en el header
  /// Parámetro: Lista de Maps con los datos de las limpiezas a crear
  Future<Response> crearLimpiezasMasivo(List<Map<String, dynamic>> limpiezasData) async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + 'limpiezas/masivo';
    final headers = {'Authorization': 'Bearer $token'};

    print('🔍 [LimpiezaService] Llamando a: $url');
    print('🔍 [LimpiezaService] Datos a enviar: ${limpiezasData.length} limpiezas');
    print('🔍 [LimpiezaService] Primer elemento: ${limpiezasData.isNotEmpty ? limpiezasData.first : 'N/A'}');

    try {
      final response = await _dio.post(
        url,
        data: limpiezasData,
        options: Options(headers: headers),
      );
      
      print('✅ [LimpiezaService] Respuesta recibida:');
      print('   Status Code: ${response.statusCode}');
      print('   Data Type: ${response.data.runtimeType}');
      print('   Data: ${response.data}');
      
      return response;
    } catch (e) {
      print('❌ [LimpiezaService] Error: $e');
      if (e is DioException) {
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
        print('   Request Path: ${e.requestOptions.path}');
      }
      rethrow;
    }
  }
}
