/// Endpoints relacionados con autenticación
/// Contiene las rutas del módulo de autenticación
class EndpointsAutenticacion {
  /// Endpoint para iniciar sesión
  /// POST /api/v1/usuarios/login
  /// Body: { "login": "usuario", "password": "contraseña" }
  static const String iniciarSesion = '/usuarios/login';
}

