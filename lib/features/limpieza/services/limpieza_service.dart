import 'package:dio/dio.dart'; // se importa libreria para hacer peticiones HTTP al backend
import 'package:image_picker/image_picker.dart'; // para XFile que funciona en web y móvil
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

  /// Método para obtener limpiezas por empleado_id
  /// Requiere token de autenticación en el header
  /// Parámetro: empleadoId del empleado
  Future<Response> fetchLimpiezasPorEmpleado(int empleadoId) async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsLimpieza.porEmpleado(empleadoId);
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
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

  /// Método para obtener el detalle completo de una limpieza
  /// Requiere token de autenticación en el header
  /// Parámetro: limpiezaId de la limpieza
  Future<Response> fetchLimpiezaDetail(int limpiezaId) async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsLimpieza.detail(limpiezaId);
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Método para iniciar una limpieza
  /// Actualiza estatus a 2 (En Progreso) y fecha_inicio_limpieza
  Future<Response> iniciarLimpieza(int limpiezaId, DateTime fechaInicio) async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsLimpieza.detail(limpiezaId);
    final headers = {'Authorization': 'Bearer $token'};

    // Formatear fecha en formato ISO 8601
    final fechaInicioStr = fechaInicio.toUtc().toIso8601String();

    final data = {
      'estatus_limpieza_id': 2,
      'fecha_inicio_limpieza': fechaInicioStr,
    };

    try {
      final response = await _dio.put(
        url,
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Método para cancelar una limpieza
  /// Actualiza estatus a 4 (Cancelada) y comentarios_observaciones
  Future<Response> cancelarLimpieza(int limpiezaId, String comentario) async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsLimpieza.detail(limpiezaId);
    final headers = {'Authorization': 'Bearer $token'};

    final data = {
      'estatus_limpieza_id': 4,
      'comentarios_observaciones': comentario,
    };

    try {
      final response = await _dio.put(
        url,
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Método para terminar una limpieza
  /// Actualiza estatus a 3 (Completada), fecha_termino y comentarios_observaciones
  Future<Response> terminarLimpieza(int limpiezaId, DateTime fechaTermino, String comentario) async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsLimpieza.detail(limpiezaId);
    final headers = {'Authorization': 'Bearer $token'};

    // Formatear fecha en formato ISO 8601
    final fechaTerminoStr = fechaTermino.toUtc().toIso8601String();

    final data = {
      'estatus_limpieza_id': 3,
      'fecha_termino': fechaTerminoStr,
      'comentarios_observaciones': comentario,
    };

    try {
      final response = await _dio.put(
        url,
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Método para subir una foto a la galería de una limpieza
  /// Requiere token de autenticación en el header
  /// Tipo de cuerpo: multipart/form-data
  /// Parámetros: limpiezaId, xFile (XFile que funciona en web y móvil) y tipo ("antes" o "despues")
  Future<Response> uploadFotoGaleria(int limpiezaId, XFile xFile, String tipo) async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsLimpieza.galeria(limpiezaId, tipo);

    // Obtener bytes del archivo usando XFile (funciona tanto en web como en móvil)
    final fileBytes = await xFile.readAsBytes();
    final filename = xFile.name.isNotEmpty 
        ? xFile.name 
        : 'limpieza_${limpiezaId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Crear FormData con el archivo usando bytes
    FormData formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        fileBytes,
        filename: filename,
      ),
    });

    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Método para obtener la galería de fotos de una limpieza
  /// Requiere token de autenticación en el header
  /// Parámetros: limpiezaId y tipo opcional ("antes", "despues" o null para ambas)
  Future<Response> fetchGaleria(int limpiezaId, String? tipo) async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    // Si tipo es null, no incluir el parámetro en la URL
    final url = tipo != null
        ? baseUrl + EndpointsLimpieza.galeria(limpiezaId, tipo)
        : baseUrl + 'limpiezas/$limpiezaId/galeria';
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Método para eliminar una foto de la galería de una limpieza
  /// Requiere token de autenticación en el header
  /// Parámetros: limpiezaId, nombreArchivo y tipo ("antes" o "despues")
  Future<Response> deleteFotoGaleria(int limpiezaId, String nombreArchivo, String tipo) async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }

    final url = baseUrl + EndpointsLimpieza.deleteFoto(limpiezaId, nombreArchivo, tipo);
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await _dio.delete(
        url,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
