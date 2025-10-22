import 'package:dio/dio.dart';
import '../../../../nucleo/utilidades/resultado.dart';
import '../../../../nucleo/errores/fallas.dart';
import '../../../../nucleo/errores/excepciones.dart';
import '../../../../nucleo/almacenamiento/almacenamiento_local.dart';
import '../../dominio/entidades/respuesta_autenticacion.dart';
import '../../dominio/repositorios/repositorio_autenticacion.dart';
import '../fuentes_datos/autenticacion_fuente_remota.dart';

/// Implementación del repositorio de autenticación
/// Conecta la fuente de datos remota con el dominio
/// Maneja la conversión de excepciones a fallas
/// Guarda y recupera datos del almacenamiento local
class RepositorioAutenticacionImpl implements RepositorioAutenticacion {
  final AutenticacionFuenteRemota fuenteRemota;
  final AlmacenamientoLocal almacenamiento;
  
  RepositorioAutenticacionImpl({
    required this.fuenteRemota,
    required this.almacenamiento,
  });
  
  @override
  Future<Resultado<RespuestaAutenticacion>> iniciarSesion({
    required String login,
    required String password,
  }) async {
    try {
      // Llamar a la fuente de datos remota
      final respuestaModelo = await fuenteRemota.iniciarSesion(
        login: login,
        password: password,
      );
      
      // Guardar token y datos del usuario en almacenamiento local
      await almacenamiento.guardarToken(respuestaModelo.tokenAcceso);
      await almacenamiento.guardarTipoToken(respuestaModelo.tipoToken);
      await almacenamiento.guardarExpiracion(respuestaModelo.expiraEn);
      await almacenamiento.guardarInformacionUsuario(
        idUsuario: respuestaModelo.informacionUsuario.id,
        login: respuestaModelo.informacionUsuario.login,
        correoElectronico: respuestaModelo.informacionUsuario.correoElectronico,
      );
      
      // Convertir modelo a entidad de dominio
      final respuestaEntidad = respuestaModelo.aEntidad();
      
      // Retornar éxito con la entidad
      return Exito(respuestaEntidad);
      
    } on ExcepcionAutenticacion catch (e) {
      // Credenciales incorrectas o datos inválidos
      return Error(FallaAutenticacion(e.mensaje));
      
    } on ExcepcionRed catch (e) {
      // Error de conexión o timeout
      return Error(FallaRed(e.mensaje));
      
    } on ExcepcionServidor catch (e) {
      // Error del servidor
      return Error(FallaServidor(e.mensaje));
      
    } on DioException catch (e) {
      // Manejar errores de Dio no capturados
      if (e.response?.statusCode == 401) {
        return const Error(
          FallaAutenticacion('Usuario o contraseña incorrectos'),
        );
      } else if (e.response?.statusCode == 422) {
        return const Error(
          FallaValidacion('Datos de login inválidos'),
        );
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        return const Error(FallaRed('Tiempo de espera agotado'));
      } else if (e.type == DioExceptionType.connectionError) {
        return const Error(FallaRed('No hay conexión a internet'));
      } else {
        return const Error(FallaServidor('Error del servidor'));
      }
      
    } catch (e) {
      // Error inesperado
      return Error(FallaDesconocida('Error inesperado: $e'));
    }
  }
}

