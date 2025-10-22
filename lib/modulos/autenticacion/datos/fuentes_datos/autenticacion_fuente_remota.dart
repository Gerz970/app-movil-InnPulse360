import 'package:dio/dio.dart';
import '../../../../nucleo/red/cliente_api_base.dart';
import '../../../../nucleo/red/endpoints/endpoints_autenticacion.dart';
import '../../../../nucleo/errores/excepciones.dart';
import '../modelos/respuesta_login_modelo.dart';

/// Contrato de la fuente de datos remota de autenticación
/// Define las operaciones que se pueden hacer con la API
abstract class AutenticacionFuenteRemota {
  /// Iniciar sesión con credenciales
  /// Retorna RespuestaLoginModelo si es exitoso
  /// Lanza ExcepcionAutenticacion si las credenciales son incorrectas
  /// Lanza ExcepcionServidor si hay error del servidor
  /// Lanza ExcepcionRed si hay error de conexión
  Future<RespuestaLoginModelo> iniciarSesion({
    required String login,
    required String password,
  });
}

/// Implementación de la fuente de datos remota de autenticación
/// Realiza las peticiones HTTP a la API usando el cliente base
class AutenticacionFuenteRemotaImpl implements AutenticacionFuenteRemota {
  final ClienteApiBase cliente;
  
  AutenticacionFuenteRemotaImpl(this.cliente);
  
  @override
  Future<RespuestaLoginModelo> iniciarSesion({
    required String login,
    required String password,
  }) async {
    try {
      // Preparar el body de la petición
      // Formato: { "login": "usuario", "password": "contraseña" }
      final body = {
        'login': login,
        'password': password,
      };
      
      // Hacer petición POST al endpoint de login
      // No requiere token de autorización (es público)
      final response = await cliente.postSinToken(
        EndpointsAutenticacion.iniciarSesion,
        body,
      );
      
      // Verificar que la respuesta sea exitosa (200-299)
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        // Debug: Imprimir la respuesta del servidor
        print('=== RESPUESTA DEL SERVIDOR ===');
        print('Status Code: ${response.statusCode}');
        print('Response Data: ${response.data}');
        print('===============================');
        
        // Convertir respuesta JSON a modelo
        return RespuestaLoginModelo.desdeJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        // Error del servidor
        throw ExcepcionServidor(
          'Error del servidor: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Manejar diferentes tipos de errores de Dio
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        // Error de timeout
        throw ExcepcionRed('Tiempo de espera agotado');
      } else if (e.type == DioExceptionType.connectionError) {
        // Error de conexión
        throw ExcepcionRed('No hay conexión a internet');
      } else if (e.response?.statusCode == 401) {
        // Credenciales incorrectas
        throw ExcepcionAutenticacion('Usuario o contraseña incorrectos');
      } else if (e.response?.statusCode == 422) {
        // Error de validación
        throw ExcepcionAutenticacion('Datos de login inválidos');
      } else if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        // Error del servidor
        throw ExcepcionServidor('Error en el servidor');
      } else {
        // Otro error
        throw ExcepcionRed('Error de conexión: ${e.message}');
      }
    } catch (e) {
      // Error inesperado
      throw ExcepcionServidor('Error inesperado: $e');
    }
  }
}

