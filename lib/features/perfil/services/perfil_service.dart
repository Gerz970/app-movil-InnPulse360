import 'package:dio/dio.dart';
import '../../../api/api_config.dart';
import '../../../api/endpoints_perfil.dart';
import '../../../core/auth/services/session_storage.dart';

class PerfilService {
  // Instancia de DIO para las peticiones HTTP
  final Dio _dio;

  // URL base de la API
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  // Constructor de la clase
  PerfilService({Dio? dio}) : _dio = dio ?? Dio() {
    // Configuración para la petición
    _dio.options.connectTimeout = Duration(seconds: ApiConfig.connectTimeoutSeconds);
    _dio.options.receiveTimeout = Duration(seconds: ApiConfig.receiveTimeoutSeconds);
    _dio.options.headers = {
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

  /// Método para obtener el perfil del usuario actual
  /// Requiere token de autenticación en el header
  Future<Response> obtenerPerfil() async {
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
    final url = baseUrl + EndpointsPerfil.obtenerPerfil;

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

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Método para actualizar el perfil del usuario actual
  /// Requiere token de autenticación en el header
  /// Parámetro: Map con los datos a actualizar
  Future<Response> actualizarPerfil(Map<String, dynamic> datos) async {
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
    final url = baseUrl + EndpointsPerfil.actualizarPerfil;

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición PUT
    try {
      final response = await _dio.put(
        url,
        data: datos,
        options: Options(headers: headers),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Método para subir una foto de perfil
  /// Requiere token de autenticación en el header
  /// Tipo de cuerpo: multipart/form-data
  /// Parámetros: idUsuario, fileBytes (bytes del archivo) y fileName (nombre del archivo)
  Future<Response> subirFotoPerfil(int idUsuario, List<int> fileBytes, String fileName) async {
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
    final url = baseUrl + EndpointsPerfil.actualizarFotoPerfil(idUsuario);

    // Obtener la extensión del archivo
    final extension = fileName.split('.').last;
    final finalFileName = 'perfil_${idUsuario}_${DateTime.now().millisecondsSinceEpoch}.$extension';

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

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Método para eliminar/restaurar foto de perfil por defecto
  /// Requiere token de autenticación en el header
  /// Parámetro: idUsuario del usuario
  Future<Response> eliminarFotoPerfil(int idUsuario) async {
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
    final url = baseUrl + EndpointsPerfil.eliminarFotoPerfil(idUsuario);

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

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Método para cambiar contraseña temporal
  /// Requiere token de autenticación en el header
  /// Parámetro: Map con los datos del cambio de contraseña
  Future<Response> cambiarPasswordTemporal(Map<String, dynamic> datos) async {
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
    final url = baseUrl + EndpointsPerfil.cambiarPasswordTemporal;

    // Configurar headers con el token de autenticación
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Hacer la petición POST
    try {
      final response = await _dio.post(
        url,
        data: datos,
        options: Options(headers: headers),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}

