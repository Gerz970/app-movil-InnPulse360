import 'package:dio/dio.dart';
import '../../almacenamiento/almacenamiento_local.dart';

/// Interceptor para agregar automáticamente el token de autorización
/// Se ejecuta antes de cada petición HTTP
class InterceptorAutenticacion extends Interceptor {
  final AlmacenamientoLocal _almacenamiento;
  
  InterceptorAutenticacion(this._almacenamiento);
  
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Verificar si esta petición requiere token de autorización
    final requiereToken = options.extra['requiereToken'] ?? false;
    
    if (requiereToken) {
      // Obtener token del almacenamiento local
      final token = await _almacenamiento.obtenerToken();
      final tipoToken = await _almacenamiento.obtenerTipoToken();
      
      if (token != null && tipoToken != null) {
        // Agregar header de autorización
        // Formato: "Authorization: Bearer token_aqui"
        options.headers['Authorization'] = '$tipoToken $token';
      }
    }
    
    // Continuar con la petición
    return handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Manejar error 401 (No autorizado)
    if (err.response?.statusCode == 401) {
      // El token ha expirado o es inválido
      // Limpiar datos de sesión
      await _almacenamiento.limpiarDatos();
      
      // Aquí se podría implementar lógica para:
      // 1. Intentar refrescar el token
      // 2. Redirigir al login
      // 3. Mostrar mensaje al usuario
    }
    
    // Continuar con el error
    return handler.next(err);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Se puede usar para logging o procesamiento de respuestas
    return handler.next(response);
  }
}

