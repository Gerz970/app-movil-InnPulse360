// aqui se definen las rutas para hacer peticiones a los endpoints especificos, se requiere utilizar
// rutas relativas es decir sin "/" al inicio por ejemplo "/usuarios/login" esto seria incorrecto
// lo correcto es "usuarios/login"

class EndpointsAuth {
  // Endpoints de autenticación

  //[POST]: login
  static const String login = "usuarios/login";
  
  //[POST]: verificar disponibilidad de login y correo para registro
  static const String verificarDisponibilidad = "usuarios/verificar-disponibilidad";
  
  //[POST]: registro de usuario-cliente
  static const String registroCliente = "usuarios/registro-cliente";
  
  //[POST]: recuperar contraseña
  static const String recuperarPassword = "usuarios/recuperar-password";
}