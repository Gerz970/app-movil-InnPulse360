/// Clase base para todas las fallas del negocio
/// Representa errores que pueden ocurrir en la aplicación
abstract class Falla {
  final String mensaje;
  
  const Falla(this.mensaje);
  
  @override
  String toString() => mensaje;
}

/// Falla de servidor
/// Ocurre cuando hay un error en el servidor (5xx)
class FallaServidor extends Falla {
  const FallaServidor([String mensaje = 'Error en el servidor. Intenta más tarde.'])
      : super(mensaje);
}

/// Falla de red
/// Ocurre cuando no hay conexión a internet o timeout
class FallaRed extends Falla {
  const FallaRed([String mensaje = 'Error de conexión. Verifica tu internet.'])
      : super(mensaje);
}

/// Falla de autenticación
/// Ocurre cuando las credenciales son incorrectas o el token es inválido
class FallaAutenticacion extends Falla {
  const FallaAutenticacion([String mensaje = 'Credenciales incorrectas.'])
      : super(mensaje);
}

/// Falla de autorización
/// Ocurre cuando el usuario no tiene permisos para acceder a un recurso
class FallaAutorizacion extends Falla {
  const FallaAutorizacion([String mensaje = 'No tienes permisos para esta acción.'])
      : super(mensaje);
}

/// Falla de validación
/// Ocurre cuando los datos enviados no son válidos
class FallaValidacion extends Falla {
  const FallaValidacion([String mensaje = 'Los datos ingresados no son válidos.'])
      : super(mensaje);
}

/// Falla no encontrada
/// Ocurre cuando un recurso no existe (404)
class FallaNoEncontrada extends Falla {
  const FallaNoEncontrada([String mensaje = 'Recurso no encontrado.'])
      : super(mensaje);
}

/// Falla desconocida
/// Para errores inesperados
class FallaDesconocida extends Falla {
  const FallaDesconocida([String mensaje = 'Ocurrió un error inesperado.'])
      : super(mensaje);
}

