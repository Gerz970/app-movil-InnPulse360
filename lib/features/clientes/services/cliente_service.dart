import 'package:dio/dio.dart'; // se importa libreria para hacer peticiones HTTP al backend
import '../../../api/api_config.dart'; // importar configuracion del api
import '../../../api/endpoints_clientes.dart'; // importar endpoints de clientes
import '../../../api/endpoints_hotels.dart'; // importar endpoints de hotels para catalogos
import '../../../core/auth/services/session_storage.dart'; // para obtener token de sesión

class ClienteService {
  //se instancia la clase de DIO para las peticiones de HTTP
  final Dio _dio;

  //URL base de la API
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  // Constructor de la clase, se inicializa validando si se proporciona una instancia del mismo objeto
  // en caso de que no se proporcione, este creara una nueva
  ClienteService({Dio? dio}) : _dio = dio ?? Dio() {
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

  /// Método para obtener el listado de clientes
  /// Requiere token de autenticación en el header
  /// Parámetros opcionales: skip y limit para paginación
  Future<Response> fetchClientes({int skip = 0, int limit = 100}) async {
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
    final url = baseUrl + EndpointsClientes.list;

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición GET
    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para crear un nuevo cliente
  /// Requiere token de autenticación en el header
  /// Parámetro: Map con los datos del cliente
  Future<Response> createCliente(Map<String, dynamic> clienteData) async {
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
    final url = baseUrl + EndpointsClientes.list;

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición POST
    try {
      final response = await _dio.post(
        url,
        data: clienteData,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método público para crear un nuevo cliente (sin autenticación)
  /// Usado durante el proceso de registro
  /// Parámetro: Map con los datos del cliente
  Future<Response> createClientePublico(Map<String, dynamic> clienteData) async {
    // Construir la URL usando el endpoint público
    final url = baseUrl + EndpointsClientes.createPublico;

    // Configurar headers sin autenticación
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Hacer la petición POST
    try {
      final response = await _dio.post(
        url,
        data: clienteData,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para obtener el detalle de un cliente
  /// Requiere token de autenticación en el header
  /// Parámetro: clienteId del cliente a obtener
  Future<Response> fetchClienteDetail(int clienteId) async {
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
    final url = baseUrl + EndpointsClientes.detail(clienteId);

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

  /// Método para actualizar un cliente
  /// Requiere token de autenticación en el header
  /// Parámetros: clienteId del cliente a actualizar y Map con los datos a actualizar
  /// Solo se pueden actualizar: nombre_razon_social, telefono, direccion, id_estatus
  Future<Response> updateCliente(int clienteId, Map<String, dynamic> clienteData) async {
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
    final url = baseUrl + EndpointsClientes.detail(clienteId);

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición PUT
    try {
      final response = await _dio.put(
        url,
        data: clienteData,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para eliminar un cliente
  /// Requiere token de autenticación en el header
  /// Parámetro: clienteId del cliente a eliminar
  Future<Response> deleteCliente(int clienteId) async {
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
    final url = baseUrl + EndpointsClientes.detail(clienteId);

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    // Hacer la petición DELETE
    try {
      final response = await _dio.delete(
        url,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  // ===== Métodos de catálogos (reutilizados de HotelService) =====

  /// Método para obtener el catálogo de países
  /// Requiere token de autenticación en el header
  /// Parámetros opcionales: skip y limit para paginación
  Future<Response> fetchPaises({int skip = 0, int limit = 100}) async {
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
    final url = baseUrl + EndpointsHotels.paises;

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Hacer la petición GET
    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
        options: Options(
          headers: headers,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para obtener el catálogo de estados
  /// Requiere token de autenticación en el header
  /// Parámetros opcionales: skip y limit para paginación, idPais para filtrar por país
  Future<Response> fetchEstados({int skip = 0, int limit = 100, int? idPais}) async {
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
    final url = baseUrl + EndpointsHotels.estados;

    // Construir query parameters
    final queryParams = <String, dynamic>{
      'skip': skip,
      'limit': limit,
    };

    // Agregar idPais si se proporciona
    if (idPais != null) {
      queryParams['id_pais'] = idPais;
    }

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición GET
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para obtener un país específico por ID
  /// Requiere token de autenticación en el header
  /// Parámetro: idPais del país a obtener
  Future<Response> fetchPaisById(int idPais) async {
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
    final url = baseUrl + EndpointsHotels.paisById(idPais);

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

  /// Método para obtener un estado específico por ID
  /// Requiere token de autenticación en el header
  /// Parámetro: idEstado del estado a obtener
  Future<Response> fetchEstadoById(int idEstado) async {
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
    final url = baseUrl + EndpointsHotels.estadoById(idEstado);

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

  // ===== Métodos públicos (sin autenticación) para registro =====

  /// Método público para obtener el catálogo de países
  /// NO requiere token de autenticación
  /// Parámetros opcionales: skip y limit para paginación
  Future<Response> fetchPaisesPublicos({int skip = 0, int limit = 100}) async {
    // Construir la URL con query parameters
    final url = baseUrl + EndpointsHotels.paises;

    // Configurar headers sin autenticación
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Hacer la petición GET
    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
        options: Options(
          headers: headers,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método público para obtener el catálogo de estados
  /// NO requiere token de autenticación
  /// Parámetros opcionales: skip y limit para paginación, idPais para filtrar por país
  Future<Response> fetchEstadosPublicos({int skip = 0, int limit = 100, int? idPais}) async {
    // Construir la URL según si se proporciona idPais
    final String url;
    final Map<String, dynamic> queryParams;

    if (idPais != null) {
      // Usar endpoint específico para estados por país
      url = baseUrl + "estados/pais/$idPais";
      queryParams = {}; // Este endpoint no acepta query parameters
    } else {
      // Usar endpoint general de estados con paginación
      url = baseUrl + EndpointsHotels.estados;
      queryParams = {
        'skip': skip,
        'limit': limit,
      };
    }

    // Configurar headers sin autenticación
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Hacer la petición GET
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }
}

