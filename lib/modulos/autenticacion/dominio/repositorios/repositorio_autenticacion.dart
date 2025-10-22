import '../../../../nucleo/utilidades/resultado.dart';
import '../entidades/respuesta_autenticacion.dart';

/// Contrato del repositorio de autenticación
/// Define las operaciones que debe implementar el repositorio
/// Este es un contrato abstracto (interface) que será implementado en la capa de datos
abstract class RepositorioAutenticacion {
  /// Iniciar sesión con credenciales
  /// Parámetros:
  ///   - login: nombre de usuario o email
  ///   - password: contraseña del usuario
  /// Retorna:
  ///   - Exito con RespuestaAutenticacion si las credenciales son correctas
  ///   - Error con Falla si ocurre algún problema
  Future<Resultado<RespuestaAutenticacion>> iniciarSesion({
    required String login,
    required String password,
  });
}

