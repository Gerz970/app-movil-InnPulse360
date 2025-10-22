import '../../../../nucleo/utilidades/resultado.dart';
import '../../../../nucleo/errores/fallas.dart';
import '../entidades/respuesta_autenticacion.dart';
import '../repositorios/repositorio_autenticacion.dart';

/// Caso de uso para iniciar sesión
/// Contiene la lógica de negocio para el proceso de login
class IniciarSesionCasoUso {
  final RepositorioAutenticacion repositorio;
  
  IniciarSesionCasoUso(this.repositorio);
  
  /// Ejecutar el caso de uso de inicio de sesión
  /// Parámetros:
  ///   - parametros: objeto con login y password
  /// Retorna:
  ///   - Exito con RespuestaAutenticacion si el login es exitoso
  ///   - Error con Falla si hay algún problema
  Future<Resultado<RespuestaAutenticacion>> ejecutar(
    ParametrosIniciarSesion parametros,
  ) async {
    // Validar que los campos no estén vacíos
    if (parametros.login.trim().isEmpty) {
      return const Error(
        FallaValidacion('El usuario no puede estar vacío'),
      );
    }
    
    if (parametros.password.trim().isEmpty) {
      return const Error(
        FallaValidacion('La contraseña no puede estar vacía'),
      );
    }
    
    // Validar longitud mínima de contraseña
    if (parametros.password.length < 6) {
      return const Error(
        FallaValidacion('La contraseña debe tener al menos 6 caracteres'),
      );
    }
    
    // Llamar al repositorio para hacer el login
    return await repositorio.iniciarSesion(
      login: parametros.login,
      password: parametros.password,
    );
  }
}

/// Parámetros para el caso de uso de iniciar sesión
/// Encapsula los datos necesarios para hacer login
class ParametrosIniciarSesion {
  final String login;
  final String password;
  
  const ParametrosIniciarSesion({
    required this.login,
    required this.password,
  });
}

