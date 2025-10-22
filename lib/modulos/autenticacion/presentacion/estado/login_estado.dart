import '../../dominio/entidades/respuesta_autenticacion.dart';

/// Estados posibles para la pantalla de login
/// Representa los diferentes estados de la UI durante el proceso de autenticación
abstract class LoginEstado {
  const LoginEstado();
}

/// Estado inicial
/// Cuando se abre la pantalla por primera vez
class LoginInicial extends LoginEstado {
  const LoginInicial();
}

/// Estado de carga
/// Cuando se está realizando la petición de login
class LoginCargando extends LoginEstado {
  const LoginCargando();
}

/// Estado de éxito
/// Cuando el login fue exitoso
class LoginExitoso extends LoginEstado {
  final RespuestaAutenticacion respuesta;
  
  const LoginExitoso(this.respuesta);
}

/// Estado de error
/// Cuando ocurrió un error durante el login
class LoginError extends LoginEstado {
  final String mensaje;
  
  const LoginError(this.mensaje);
}

