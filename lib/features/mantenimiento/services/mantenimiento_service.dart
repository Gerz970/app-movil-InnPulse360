import 'package:app_movil_innpulse/features/mantenimiento/models/mantenimiento_model.dart';
import 'package:dio/dio.dart'; // se importa libreria para hacer peticiones HTTP al backend
import '../../../api/api_config.dart'; // importar configuracion del api
import '../../../api/endpoints_incidencias.dart'; // importar endpoints de incidencias
import '../../../api/endpoints_mantenimiento.dart'; // importar endpoints de reservaciones
import '../../../core/auth/services/session_storage.dart'; // para obtener token de sesión


class MantenimientoService {
  final Dio _dio;

  //URL base de la API
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  // Constructor de la clase, se inicializa validando si se proporciona una instancia del mismo objeto
  // en caso de que no se proporcione, este creara una nueva
  MantenimientoService({Dio? dio}) : _dio = dio ?? Dio() {
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

  Future<List<Mantenimiento>> fetchMantenimiento() async {
  final token = await _getToken();
  if (token == null) {
    throw Exception("NOT_AUTH");
  }

  // Obtener id_empleado de la sesión
  final session = await SessionStorage.getSession();
  final usuario = session?['usuario'] as Map<String, dynamic>?;
  print('Usuario: $usuario');

  final int? idEmpleado = usuario?["empleado_id"];

  if (idEmpleado == null) {
    throw Exception("El usuario no tiene id_empleado en la sesión");
  }

  final String url = baseUrl +
      EndpointsMantenimiento.obtener_por_empleado_estatus(idEmpleado, 1);

  final response = await _dio.get(
    url,
    options: Options(headers: {
      "Authorization": "Bearer $token",
    }),
  );

  // Convertir respuesta a lista
  final data = response.data;

  if (data is! List) {
    throw Exception("El backend no devolvió una lista");
  }

    return data.map((e) => Mantenimiento.fromJson(e)).toList();
  }

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
    final url = baseUrl + EndpointsMantenimiento.galeria(incidenciaId);

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
    final url = baseUrl + EndpointsMantenimiento.galeria(incidenciaId);

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
}
