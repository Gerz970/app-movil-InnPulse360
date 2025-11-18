import 'package:dio/dio.dart'; // se importa libreria para hacer peticiones HTTP al backend
import '../../../api/api_config.dart'; // importar configuracion del api
import '../../../api/endpoints_hotels.dart'; // importar endpoints de hoteles
import '../../../core/auth/services/session_storage.dart'; // para obtener token de sesión

class HotelService {
  //se instancia la clase de DIO para las peticiones de HTTP
  final Dio _dio;

  //URL base de la API
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  // Constructor de la clase, se inicializa validando si se proporciona una instancia del mismo objeto
  // en caso de que no se proporcione, este creara una nueva
  HotelService({Dio? dio}) : _dio = dio ?? Dio() {
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
      return null;
    }
  }

  /// Método para obtener el listado de hoteles
  /// Requiere token de autenticación en el header
  /// Parámetros opcionales: skip y limit para paginación
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
    final url = baseUrl + EndpointsHotels.list;

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
  /// Retorna lista de estados
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

    // Hacer la petición GET con timeout extendido para peticiones secundarias
    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: headers,
          receiveTimeout: Duration(seconds: 60), // Timeout extendido para peticiones secundarias
          sendTimeout: Duration(seconds: 60),
        ),
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

    // Hacer la petición GET con timeout extendido para peticiones secundarias
    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: headers,
          receiveTimeout: Duration(seconds: 60), // Timeout extendido para peticiones secundarias
          sendTimeout: Duration(seconds: 60),
        ),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para crear un nuevo hotel
  /// Requiere token de autenticación en el header
  /// Parámetro: Map con los datos del hotel
  Future<Response> createHotel(Map<String, dynamic> hotelData) async {
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
    final url = baseUrl + EndpointsHotels.list;

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición POST
    try {
      final response = await _dio.post(
        url,
        data: hotelData,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para obtener el detalle de un hotel
  /// Requiere token de autenticación en el header
  /// Parámetro: hotelId del hotel a obtener
  Future<Response> fetchHotelDetail(int hotelId) async {
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
    final url = baseUrl + EndpointsHotels.detail(hotelId);

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

  /// Método para actualizar un hotel
  /// Requiere token de autenticación en el header
  /// Parámetros: hotelId del hotel a actualizar y Map con los datos a actualizar
  /// Se pueden actualizar: nombre, direccion, codigo_postal, id_pais, id_estado, telefono, numero_estrellas
  Future<Response> updateHotel(int hotelId, Map<String, dynamic> hotelData) async {
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
    final url = baseUrl + EndpointsHotels.detail(hotelId);

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición PUT
    try {
      final response = await _dio.put(
        url,
        data: hotelData,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para eliminar un hotel
  /// Requiere token de autenticación en el header
  /// Parámetro: hotelId del hotel a eliminar
  Future<Response> deleteHotel(int hotelId) async {
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
    final url = baseUrl + EndpointsHotels.detail(hotelId);

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

  /// Método para subir una foto de hotel
  /// Requiere token de autenticación en el header
  /// Tipo de cuerpo: multipart/form-data
  /// Parámetros: idHotel, fileBytes (bytes del archivo) y fileName (nombre del archivo)
  Future<Response> subirFotoHotel(int idHotel, List<int> fileBytes, String fileName) async {
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
    final url = baseUrl + EndpointsHotels.actualizarFotoHotel(idHotel);

    // Obtener la extensión del archivo
    final extension = fileName.split('.').last;
    final finalFileName = 'hotel_${idHotel}_${DateTime.now().millisecondsSinceEpoch}.$extension';

    // Crear FormData con el archivo usando bytes (compatible con todas las plataformas)
    FormData formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        fileBytes,
        filename: finalFileName,
      ),
    });

    // Configurar headers con el token de autenticación
    // No incluir Content-Type para multipart, Dio lo maneja automáticamente
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición PUT con multipart
    try {
      final response = await _dio.put(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para eliminar/restaurar foto de hotel por defecto
  /// Requiere token de autenticación en el header
  /// Parámetro: idHotel del hotel
  Future<Response> eliminarFotoHotel(int idHotel) async {
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
    final url = baseUrl + EndpointsHotels.eliminarFotoHotel(idHotel);

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

  /// Método para subir una imagen a la galería del hotel
  /// Requiere token de autenticación en el header
  /// Tipo de cuerpo: multipart/form-data
  /// Parámetros: idHotel, fileBytes (bytes del archivo) y fileName (nombre del archivo)
  Future<Response> subirImagenGaleria(int idHotel, List<int> fileBytes, String fileName) async {
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
    final url = baseUrl + EndpointsHotels.subirImagenGaleria(idHotel);

    // Obtener la extensión del archivo
    final extension = fileName.split('.').last;
    final finalFileName = 'galeria_${idHotel}_${DateTime.now().millisecondsSinceEpoch}.$extension';

    // Crear FormData con el archivo usando bytes (compatible con todas las plataformas)
    FormData formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        fileBytes,
        filename: finalFileName,
      ),
    });

    // Configurar headers con el token de autenticación
    // No incluir Content-Type para multipart, Dio lo maneja automáticamente
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición POST con multipart
    try {
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para listar las imágenes de la galería del hotel
  /// Requiere token de autenticación en el header
  /// Parámetro: idHotel del hotel
  Future<Response> listarGaleria(int idHotel) async {
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
    final url = baseUrl + EndpointsHotels.listarGaleria(idHotel);

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

  /// Método para eliminar una imagen de la galería del hotel
  /// Requiere token de autenticación en el header
  /// Parámetros: idHotel del hotel y nombreArchivo de la imagen a eliminar
  Future<Response> eliminarImagenGaleria(int idHotel, String nombreArchivo) async {
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
    final url = baseUrl + EndpointsHotels.eliminarImagenGaleria(idHotel, nombreArchivo);

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
}

