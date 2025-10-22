import 'package:dio/dio.dart';
import 'configuracion_api.dart';
import 'interceptores/interceptor_autenticacion.dart';
import '../almacenamiento/almacenamiento_local.dart';

/// Cliente HTTP base para todas las peticiones a la API
/// Configurado con Dio y interceptores necesarios
class ClienteApiBase {
  late final Dio _dio;
  
  ClienteApiBase(AlmacenamientoLocal almacenamiento) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ConfiguracionApi.urlCompleta,
        connectTimeout: ConfiguracionApi.tiempoConexion,
        receiveTimeout: ConfiguracionApi.tiempoRecepcion,
        headers: ConfiguracionApi.headersBase,
      ),
    );
    
    // Agregar interceptor de autenticación
    _dio.interceptors.add(InterceptorAutenticacion(almacenamiento));
    
    // Interceptor de logging para desarrollo (opcional)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }
  
  /// Realizar petición POST sin token de autorización
  /// Usado para login
  Future<Response> postSinToken(String endpoint, dynamic data) async {
    return await _dio.post(endpoint, data: data);
  }
}

