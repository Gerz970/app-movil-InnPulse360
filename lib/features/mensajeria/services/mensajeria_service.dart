import 'package:dio/dio.dart';
import '../../../api/api_config.dart';
import '../../../core/auth/services/session_storage.dart';
import '../models/conversacion_model.dart';
import '../models/mensaje_model.dart';
import '../models/usuario_chat_model.dart';

class MensajeriaService {
  final Dio _dio;
  final String baseUrl = ApiConfig.baseUrl + ApiConfig.apiVersion;

  MensajeriaService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = Duration(
      seconds: ApiConfig.connectTimeoutSeconds,
    );
    _dio.options.receiveTimeout = Duration(
      seconds: ApiConfig.receiveTimeoutSeconds,
    );
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

      final token =
          session['token'] ??
          session['access_token'] ??
          session['accessToken'] || session['token_access'];

      return token is String ? token : null;
    } catch (e) {
      print('Error al obtener token: $e');
      return null;
    }
  }

  /// Obtener headers con autenticación
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    if (token == null) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'No hay token de autenticación disponible',
        type: DioExceptionType.unknown,
      );
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  /// Obtener lista de conversaciones del usuario
  Future<List<ConversacionModel>> fetchConversaciones({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '${baseUrl}mensajeria/conversaciones';
      print('🔵 MensajeriaService: Obteniendo conversaciones desde: $url');
      print('🔵 MensajeriaService: Headers: ${headers.keys}');
      
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      print('🔵 MensajeriaService: Respuesta recibida - Status: ${response.statusCode}');
      print('🔵 MensajeriaService: Tipo de datos: ${response.data.runtimeType}');
      
      if (response.data is List) {
        final lista = (response.data as List)
            .map((json) {
              try {
                return ConversacionModel.fromJson(json);
              } catch (e) {
                print('❌ Error parseando conversación: $e');
                print('❌ JSON: $json');
                rethrow;
              }
            })
            .toList();
        print('🔵 MensajeriaService: Conversaciones parseadas: ${lista.length}');
        return lista;
      }
      print('⚠️ MensajeriaService: Respuesta no es una lista, retornando lista vacía');
      return [];
    } on DioException catch (e) {
      print('❌ Error DioException al obtener conversaciones:');
      print('❌ Tipo: ${e.type}');
      print('❌ Mensaje: ${e.message}');
      print('❌ URL intentada: ${e.requestOptions.uri}');
      if (e.response != null) {
        print('❌ Status Code: ${e.response?.statusCode}');
        print('❌ Response Data: ${e.response?.data}');
      }
      
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Error de conexión. Verifica tu conexión a internet y que el servidor esté disponible en ${ApiConfig.baseUrl}');
      } else if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;
        throw Exception('Error del servidor ($statusCode): ${errorData ?? 'Sin detalles'}');
      } else {
        throw Exception('Error al cargar conversaciones: ${e.message}');
      }
    } catch (e) {
      print('❌ Error inesperado al obtener conversaciones: $e');
      print('❌ Tipo: ${e.runtimeType}');
      throw Exception('Error inesperado al cargar conversaciones: $e');
    }
  }

  /// Obtener detalle de una conversación
  Future<ConversacionModel> fetchConversacion(int conversacionId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${baseUrl}mensajeria/conversaciones/$conversacionId',
        options: Options(headers: headers),
      );

      return ConversacionModel.fromJson(response.data);
    } catch (e) {
      print('Error al obtener conversación: $e');
      rethrow;
    }
  }

  /// Crear conversación cliente-admin
  Future<ConversacionModel> crearConversacionClienteAdmin({
    required int clienteId,
    required int adminId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '${baseUrl}mensajeria/conversaciones/cliente-admin',
        options: Options(headers: headers),
        data: {
          'cliente_id': clienteId,
          'admin_id': adminId,
        },
      );

      return ConversacionModel.fromJson(response.data);
    } catch (e) {
      print('Error al crear conversación cliente-admin: $e');
      rethrow;
    }
  }

  /// Crear conversación empleado-empleado
  Future<ConversacionModel> crearConversacionEmpleadoEmpleado({
    required int empleado1Id,
    required int empleado2Id,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '${baseUrl}mensajeria/conversaciones/empleado-empleado',
        options: Options(headers: headers),
        data: {
          'empleado1_id': empleado1Id,
          'empleado2_id': empleado2Id,
        },
      );

      return ConversacionModel.fromJson(response.data);
    } catch (e) {
      print('Error al crear conversación empleado-empleado: $e');
      rethrow;
    }
  }

  /// Obtener mensajes de una conversación
  Future<List<MensajeModel>> fetchMensajes({
    required int conversacionId,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${baseUrl}mensajeria/conversaciones/$conversacionId/mensajes',
        options: Options(headers: headers),
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => MensajeModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener mensajes: $e');
      rethrow;
    }
  }

  /// Enviar mensaje
  Future<MensajeModel> enviarMensaje({
    required int conversacionId,
    required String contenido,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '${baseUrl}mensajeria/conversaciones/$conversacionId/mensajes',
        options: Options(headers: headers),
        data: {
          'conversacion_id': conversacionId,
          'contenido': contenido,
        },
      );

      return MensajeModel.fromJson(response.data);
    } catch (e) {
      print('Error al enviar mensaje: $e');
      rethrow;
    }
  }

  /// Marcar mensaje como leído
  Future<MensajeModel> marcarMensajeLeido(int mensajeId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '${baseUrl}mensajeria/mensajes/$mensajeId/leido',
        options: Options(headers: headers),
      );

      return MensajeModel.fromJson(response.data);
    } catch (e) {
      print('Error al marcar mensaje como leído: $e');
      rethrow;
    }
  }

  /// Buscar usuarios disponibles para iniciar conversación
  Future<List<UsuarioChatModel>> buscarUsuarios({String? query}) async {
    try {
      final headers = await _getHeaders();
      final url = '${baseUrl}mensajeria/conversaciones/buscar-usuario';
      print('🔵 MensajeriaService: Buscando usuarios desde: $url');
      print('🔵 MensajeriaService: Query: $query');
      
      // Construir queryParameters correctamente - usar diccionario vacío si query es null
      final queryParams = <String, dynamic>{};
      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }
      
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
        queryParameters: queryParams,
      );

      print('🔵 MensajeriaService: Respuesta recibida - Status: ${response.statusCode}');
      print('🔵 MensajeriaService: Tipo de datos: ${response.data.runtimeType}');

      // Validar que la respuesta sea una lista
      if (response.data is! List) {
        print('⚠️ MensajeriaService: Respuesta no es una lista, tipo recibido: ${response.data.runtimeType}');
        // Si la respuesta es un mapa con un mensaje de error, extraerlo
        if (response.data is Map<String, dynamic>) {
          final errorData = response.data as Map<String, dynamic>;
          final errorMessage = errorData['detail'] ?? errorData['message'] ?? 'Formato de respuesta inválido';
          throw Exception('Error del servidor: $errorMessage');
        }
        return [];
      }

      // Parsear la lista de usuarios
      final lista = (response.data as List)
          .map((json) {
            try {
              return UsuarioChatModel.fromJson(json);
            } catch (e) {
              print('❌ Error parseando usuario: $e');
              print('❌ JSON: $json');
              throw Exception('Error al procesar datos del usuario: $e');
            }
          })
          .toList();
      
      print('🔵 MensajeriaService: Usuarios parseados: ${lista.length}');
      return lista;
    } on DioException catch (e) {
      print('❌ Error DioException al buscar usuarios:');
      print('❌ Tipo: ${e.type}');
      print('❌ Mensaje: ${e.message}');
      print('❌ URL intentada: ${e.requestOptions.uri}');
      
      // Distinguir entre diferentes tipos de errores
      String errorMessage;
      
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Error de conexión. Verifica tu conexión a internet y que el servidor esté disponible.';
      } else if (e.type == DioExceptionType.badResponse && e.response != null) {
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;
        
        if (statusCode == 401) {
          errorMessage = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
        } else if (statusCode == 403) {
          errorMessage = 'No tienes permiso para realizar esta acción.';
        } else if (statusCode == 404) {
          errorMessage = 'Recurso no encontrado.';
        } else if (statusCode != null && statusCode >= 500) {
          errorMessage = 'Error del servidor. Por favor, intenta más tarde.';
        } else {
          // Extraer mensaje de error del servidor si está disponible
          if (errorData is Map<String, dynamic>) {
            final detail = errorData['detail'] ?? errorData['message'];
            errorMessage = detail?.toString() ?? 'Error al buscar usuarios (${statusCode})';
          } else {
            errorMessage = 'Error al buscar usuarios (${statusCode})';
          }
        }
        
        print('❌ Status Code: $statusCode');
        print('❌ Response Data: $errorData');
      } else {
        errorMessage = 'Error al buscar usuarios: ${e.message ?? "Error desconocido"}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      // Si ya es una Exception con mensaje descriptivo, re-lanzarla
      if (e is Exception && e.toString().contains('Error')) {
        rethrow;
      }
      
      print('❌ Error inesperado al buscar usuarios: $e');
      print('❌ Tipo: ${e.runtimeType}');
      throw Exception('Error inesperado al buscar usuarios: $e');
    }
  }

  /// Obtener contador de mensajes no leídos
  Future<int> obtenerContadorNoLeidos() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${baseUrl}mensajeria/conversaciones/no-leidos',
        options: Options(headers: headers),
      );

      return response.data['contador_no_leidos'] as int? ?? 0;
    } catch (e) {
      print('Error al obtener contador no leídos: $e');
      return 0;
    }
  }

  /// Archivar conversación
  Future<ConversacionModel> archivarConversacion(int conversacionId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '${baseUrl}mensajeria/conversaciones/$conversacionId/archivar',
        options: Options(headers: headers),
      );

      return ConversacionModel.fromJson(response.data);
    } catch (e) {
      print('Error al archivar conversación: $e');
      rethrow;
    }
  }
}

