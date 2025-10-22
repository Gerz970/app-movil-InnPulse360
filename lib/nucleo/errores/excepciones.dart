/// Clase base para todas las excepciones de la capa de datos
class ExcepcionServidor implements Exception {
  final String mensaje;
  
  ExcepcionServidor(this.mensaje);
  
  @override
  String toString() => mensaje;
}

/// Excepción de cache
/// Cuando no se pueden leer/escribir datos en cache
class ExcepcionCache implements Exception {
  final String mensaje;
  
  ExcepcionCache([this.mensaje = 'Error al acceder al almacenamiento local']);
  
  @override
  String toString() => mensaje;
}

/// Excepción de red
/// Cuando falla la conexión HTTP
class ExcepcionRed implements Exception {
  final String mensaje;
  
  ExcepcionRed([this.mensaje = 'Error de conexión de red']);
  
  @override
  String toString() => mensaje;
}

/// Excepción de autenticación
/// Cuando las credenciales son incorrectas
class ExcepcionAutenticacion implements Exception {
  final String mensaje;
  
  ExcepcionAutenticacion([this.mensaje = 'Error de autenticación']);
  
  @override
  String toString() => mensaje;
}

