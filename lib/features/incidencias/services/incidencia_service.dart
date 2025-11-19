import 'package:dio/dio.dart'; // se importa libreria para hacer peticiones HTTP al backend
import '../../../api/api_config.dart'; // importar configuracion del api
import '../../../api/endpoints_incidencias.dart'; // importar endpoints de incidencias
import '../../../api/endpoints_reservacion.dart'; // importar endpoints de reservaciones
import '../../../core/auth/services/session_storage.dart'; // para obtener token de sesión

class IncidenciaService {
  //se instancia la clase de DIO para las peticiones de HTTP
  final Dio _dio;

  //URL base de la API
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  // Constructor de la clase, se inicializa validando si se proporciona una instancia del mismo objeto
  // en caso de que no se proporcione, este creara una nueva
  IncidenciaService({Dio? dio}) : _dio = dio ?? Dio() {
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
                   session['accessToken'] ||
                   session['token_access'];
      
      return token is String ? token : null;
    } catch (e) {
      print('Error al obtener token: $e');
      return null;
    }
  }

  /// Método para obtener el listado de incidencias
  /// Requiere token de autenticación en el header
  Future<Response> fetchIncidencias() async {
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
    final url = baseUrl + EndpointsIncidencias.list;

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

  /// Método para crear una nueva incidencia
  /// Requiere token de autenticación en el header
  /// Parámetro: Map con los datos de la incidencia
  Future<Response> createIncidencia(Map<String, dynamic> incidenciaData) async {
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
    final url = baseUrl + EndpointsIncidencias.list;

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición POST
    try {
      final response = await _dio.post(
        url,
        data: incidenciaData,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para obtener el detalle de una incidencia
  /// Requiere token de autenticación en el header
  /// Parámetro: incidenciaId de la incidencia a obtener
  Future<Response> fetchIncidenciaDetail(int incidenciaId) async {
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
    final url = baseUrl + EndpointsIncidencias.detail(incidenciaId);

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

  /// Método para actualizar una incidencia
  /// Requiere token de autenticación en el header
  /// Parámetros: incidenciaId de la incidencia a actualizar y Map con los datos a actualizar
  Future<Response> updateIncidencia(int incidenciaId, Map<String, dynamic> incidenciaData) async {
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
    final url = baseUrl + EndpointsIncidencias.detail(incidenciaId);

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición PUT
    try {
      final response = await _dio.put(
        url,
        data: incidenciaData,
        options: Options(headers: headers),
      );

      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para eliminar una incidencia
  /// Requiere token de autenticación en el header
  /// Parámetro: incidenciaId de la incidencia a eliminar
  Future<Response> deleteIncidencia(int incidenciaId) async {
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
    final url = baseUrl + EndpointsIncidencias.detail(incidenciaId);

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

  /// Método para obtener la galería de una incidencia
  /// Requiere token de autenticación en el header
  /// Parámetro: incidenciaId de la incidencia
  Future<Response> fetchGaleria(int incidenciaId) async {
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
    final url = baseUrl + EndpointsIncidencias.galeria(incidenciaId);

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    // Hacer la petición GET
    try {
      print('📸 Cargando galería para incidencia: $incidenciaId');
      print('URL: $url');
      
      final response = await _dio.get(
        url,
        options: Options(
          headers: headers,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      print('✅ Galería cargada. Status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores
      print('❌ Error al cargar galería: $e');
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
      }
      rethrow;
    }
  }

  /// Método para subir una foto a la galería de una incidencia
  /// Requiere token de autenticación en el header
  /// Tipo de cuerpo: multipart/form-data
  /// Parámetros: incidenciaId y filePath del archivo a subir
  Future<Response> uploadFotoGaleria(int incidenciaId, String filePath) async {
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
    final url = baseUrl + EndpointsIncidencias.galeria(incidenciaId);

    // Crear FormData con el archivo
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: 'incidencia_${incidenciaId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
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

  /// Método para obtener una habitación/área por ID
  /// Requiere token de autenticación en el header
  /// Parámetro: habitacionAreaId del habitación/área
  Future<Response> fetchHabitacionArea(int habitacionAreaId) async {
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
    final url = baseUrl + 'habitacion-area/$habitacionAreaId';

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

  /// Método para obtener habitaciones reservadas por el cliente
  /// Requiere token de autenticación en el header
  /// Parámetro: clienteId del cliente
  Future<Response> fetchHabitacionesReservadasCliente(int clienteId) async {
    print('🔐 Obteniendo token de autenticación...');
    // Obtener token de la sesión
    final token = await _getToken();
    print('🎫 Token obtenido: ${token != null ? "SI" : "NO"}');

    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    // Construir la URL
    final url = baseUrl + EndpointsReservacion.habitacionesReservadasCliente(clienteId);
    print('🌐 URL construida: $url');

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición GET
    try {
      print('📡 Enviando petición GET...');
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      );
      print('✅ Respuesta obtenida. Status: ${response.statusCode}');

      return response; // Respuesta del API
    } catch (e) {
      print('❌ Error en petición: $e');
      // Manejo de errores
      rethrow;
    }
  }

  /// Método para eliminar una imagen de la galería de una incidencia
  /// Requiere token de autenticación en el header
  /// Parámetros: incidenciaId y nombreArchivo de la imagen a eliminar
  Future<Response> deleteFotoGaleria(int incidenciaId, String nombreArchivo) async {
    // Obtener token de la sesión
    final token = await _getToken();
    
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    // Limpiar el nombre del archivo: puede venir con ruta completa o solo el nombre
    // Extraer solo el nombre del archivo si viene con ruta
    String nombreArchivoLimpio = nombreArchivo;
    if (nombreArchivo.contains('/')) {
      nombreArchivoLimpio = nombreArchivo.split('/').last;
    }
    if (nombreArchivoLimpio.contains('\\')) {
      nombreArchivoLimpio = nombreArchivoLimpio.split('\\').last;
    }
    
    // Intentar primero sin codificar, luego con codificación si falla
    // Algunos servidores esperan el nombre sin codificar
    String nombreArchivoFinal = nombreArchivoLimpio;
    
    // Construir la URL con el nombre del archivo
    // Formato: api/v1/incidencias/{id_incidencia}/galeria/{nombre_archivo}
    String url = baseUrl + EndpointsIncidencias.galeriaImagen(incidenciaId, nombreArchivoFinal);

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    // Hacer la petición DELETE
    try {
      print('🗑️ Eliminando foto');
      print('   Nombre original: $nombreArchivo');
      print('   Nombre limpio: $nombreArchivoLimpio');
      print('   Nombre final: $nombreArchivoFinal');
      print('   URL completa: $url');
      print('   Método: DELETE');
      
      final response = await _dio.delete(
        url,
        options: Options(
          headers: headers,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('✅ Respuesta DELETE recibida. Status: ${response.statusCode}');
      print('   Response data: ${response.data}');
      
      // Si la respuesta es exitosa, retornar
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response;
      }
      
      // Si el status code es 404, puede ser que necesitemos codificar el nombre
      if (response.statusCode == 404) {
        print('⚠️ Status 404 recibido. Intentando con nombre codificado...');
        final nombreArchivoCodificado = Uri.encodeComponent(nombreArchivoLimpio);
        final urlCodificada = baseUrl + EndpointsIncidencias.galeriaImagen(incidenciaId, nombreArchivoCodificado);
        
        print('   Intentando con nombre codificado: $nombreArchivoCodificado');
        print('   Nueva URL: $urlCodificada');
        
        final responseCodificada = await _dio.delete(
          urlCodificada,
          options: Options(
            headers: headers,
            followRedirects: true,
            validateStatus: (status) => status != null && status < 500,
          ),
        );
        
        print('✅ Respuesta DELETE con codificación. Status: ${responseCodificada.statusCode}');
        return responseCodificada;
      }
      
      return response; // Respuesta del API
    } catch (e) {
      // Manejo de errores con más detalle
      print('❌ Error al eliminar foto: $e');
      if (e is DioException) {
        print('   Tipo de error: ${e.type}');
        print('   Status code: ${e.response?.statusCode}');
        print('   Response data: ${e.response?.data}');
        print('   Request path: ${e.requestOptions.path}');
        
        // Si es 404, intentar con nombre codificado
        if (e.response?.statusCode == 404) {
          try {
            print('⚠️ Error 404. Intentando con nombre codificado...');
            final nombreArchivoCodificado = Uri.encodeComponent(nombreArchivoLimpio);
            final urlCodificada = baseUrl + EndpointsIncidencias.galeriaImagen(incidenciaId, nombreArchivoCodificado);
            
            print('   Intentando con nombre codificado: $nombreArchivoCodificado');
            print('   Nueva URL: $urlCodificada');
            
            final responseCodificada = await _dio.delete(
              urlCodificada,
              options: Options(
                headers: headers,
                followRedirects: true,
                validateStatus: (status) => status != null && status < 500,
              ),
            );
            
            print('✅ Respuesta DELETE con codificación. Status: ${responseCodificada.statusCode}');
            return responseCodificada;
          } catch (e2) {
            print('❌ Error también con nombre codificado: $e2');
            rethrow;
          }
        }
      }
      rethrow;
    }
  }
}

